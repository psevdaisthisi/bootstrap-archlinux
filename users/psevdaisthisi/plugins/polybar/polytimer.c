#include <stdio.h>
#include <string.h>

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>


static volatile int g_update_time = 0;
#define UNUSED_PARAM(x) (void)(x)
static void sig_alarm_handler (int s) { UNUSED_PARAM(s); g_update_time = 1; }

static char * print_timer (int secs, char * str, const size_t len)
{
	const int h = secs / 3600;
	const int m = (secs - 3600 * h) / 60;
	const int s = secs - 3600 * h - 60 * m;

	snprintf(str, len, "%02dh:%02dm:%02ds", h, m, s);

	return str;
}

static void start_timer ()
{
	const struct itimerval cfg = {
		.it_interval = { .tv_sec = 1, .tv_usec = 0 },
		.it_value = { .tv_sec = 1, .tv_usec = 0 }
	};
	setitimer(ITIMER_REAL, &cfg, 0);
}

static void stop_timer ()
{
	const struct itimerval cfg = {
		.it_interval = { .tv_sec = 0, .tv_usec = 0 },
		.it_value = { .tv_sec = 0, .tv_usec = 0 }
	};
	setitimer(ITIMER_REAL, &cfg, 0);
}

int main (int argc, char **argv)
{
	if (argc != 2) {
		fprintf(stderr, "Invalid number of args. Usage: polytimer <fifo>\n");
		return 1;
	}

	const int fd = open(argv[1], O_RDONLY | O_NONBLOCK);
	if (fd == -1) {
		fprintf(stderr, "Failed to open '%s'. `errno' got set to %d\n", argv[1], errno);
		return 1;
	}

	enum {
		STATE_INIT,
		STATE_START,
		STATE_PAUSE,
		STATE_FINISH,
		STATE_CHANGE_UNIT
	} state = STATE_INIT;

	enum {
		CMD_NONE,
		CMD_START,
		CMD_PAUSE,
		CMD_RESET,
		CMD_INCREASE,
		CMD_DECREASE,
		CMD_CHANGE_UNIT,
		CMD_NEXT_UNIT,
	} cmd = CMD_NONE;

	enum {
		UNITS_SEC,
		UNITS_MIN,
		UNITS_HOR,
	} units = UNITS_MIN;
	int step = 5;

	#define CMD_STR_SIZE 16
	#define TIMER_STR_SIZE 32
	char cmdstr[CMD_STR_SIZE] = { '\0' };
	char timerstr[TIMER_STR_SIZE] = { '\0' };

	ssize_t nbytes = 0;
	int time_remaining = 0, prev_time_remaining = -1;

	#define DEFAULT_SLEEP_TIME_NS 1000 * 1000 * 70
	#define FINISH_SLEEP_TIME_NS 1000 * 1000 * 125
	struct timespec sleepreq = {
		.tv_sec = 0,
		.tv_nsec = DEFAULT_SLEEP_TIME_NS
	};

	struct sigaction sigalarm_cfg;
	sigemptyset(&sigalarm_cfg.sa_mask);
	sigalarm_cfg.sa_flags = 0;
	sigalarm_cfg.sa_handler = sig_alarm_handler;
	sigaction(SIGALRM, &sigalarm_cfg, 0);

	for (;;) {
		nbytes = read(fd, cmdstr, CMD_STR_SIZE - 1);

		if (nbytes > 0) {
			if (strncmp("left-click", cmdstr, 10) == 0 && state == STATE_CHANGE_UNIT)
				cmd = CMD_CHANGE_UNIT;
			else if (strncmp("left-click", cmdstr, 10) == 0)
				cmd = CMD_START;
			else if (strncmp("right-click", cmdstr, 11) == 0 && state == STATE_CHANGE_UNIT)
				cmd = CMD_NEXT_UNIT;
			else if (strncmp("right-click", cmdstr, 10) == 0 && state == STATE_INIT)
				cmd = CMD_CHANGE_UNIT;
			else if (strncmp("right-click", cmdstr, 11) == 0 && state == STATE_START)
				cmd = CMD_PAUSE;
			else if (strncmp("middle-click", cmdstr, 5) == 0)
				cmd = CMD_RESET;
			else if (strncmp("scroll-up", cmdstr, 9) == 0)
				cmd = CMD_INCREASE;
			else if (strncmp("scroll-down", cmdstr, 11) == 0)
				cmd = CMD_DECREASE;
		}
		else if (nbytes == -1) {
			fprintf(stdout, "Failed to read '%s'. `errno' got set to %d\n", argv[1], errno);
			nanosleep(&sleepreq, 0);
			return 1;
		}

		if (state == STATE_INIT) {
			if (cmd == CMD_START && time_remaining > 0) {
				start_timer();
				state = STATE_START;
			}
			else if (cmd == CMD_RESET) {
				if (time_remaining == 0) {
					units = UNITS_MIN;
					step = 5;
				}
				time_remaining = 0;
			}
			else if (cmd == CMD_INCREASE) {
				switch (units) {
				case UNITS_SEC:
					time_remaining += step;
					break;
				case UNITS_MIN:
					time_remaining += 60 * step;
					break;
				case UNITS_HOR:
					time_remaining += 3600 * step;
					break;
				}
			}
			else if (cmd == CMD_DECREASE) {
				switch (units) {
				case UNITS_SEC:
					if (step <= time_remaining)
						time_remaining -= step;
					break;
				case UNITS_MIN:
					if (60 * step <= time_remaining)
						time_remaining -= 60 * step;
					break;
				case UNITS_HOR:
					if (3600 * step <= time_remaining)
						time_remaining -= 3600 * step;
					break;
				}
			}
			else if (cmd == CMD_CHANGE_UNIT)
				state = STATE_CHANGE_UNIT;

			if (prev_time_remaining != time_remaining) {
				fprintf(stderr, "%s\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
				prev_time_remaining = time_remaining;
			}
		}

		else if (state == STATE_START) {
			if (cmd == CMD_PAUSE) {
				stop_timer();
				state = STATE_PAUSE;
				fprintf(stderr, "%s - paused\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
			}
			else if (cmd == CMD_RESET) {
				stop_timer();
				time_remaining = 0;
				state = STATE_INIT;
				fprintf(stderr, "%s\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
			}
			else if (g_update_time && time_remaining > 0) {
				time_remaining -= 1;
				g_update_time = 0;
				fprintf(stderr, "%s\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
			}
			else if (g_update_time && time_remaining == 0) {
				g_update_time = 0;
				start_timer();
				state = STATE_FINISH;
				sleepreq.tv_nsec = FINISH_SLEEP_TIME_NS;
				fprintf(stderr, "%s\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
			}
		}

		else if (state == STATE_PAUSE) {
			if (cmd == CMD_START) {
				start_timer();
				state = STATE_START;
			}
			else if (cmd == CMD_RESET) {
				time_remaining = 0;
				state = STATE_INIT;
			}
			else if (cmd == CMD_INCREASE) {
				switch (units) {
				case UNITS_SEC:
					time_remaining += step;
					break;
				case UNITS_MIN:
					time_remaining += 60 * step;
					break;
				case UNITS_HOR:
					time_remaining += 3600 * step;
					break;
				}
			}
			else if (cmd == CMD_DECREASE) {
				switch (units) {
				case UNITS_SEC:
					if (step <= time_remaining)
						time_remaining -= step;
					break;
				case UNITS_MIN:
					if (60 * step <= time_remaining)
						time_remaining -= 60 * step;
					break;
				case UNITS_HOR:
					if (3600 * step <= time_remaining)
						time_remaining -= 3600 * step;
					break;
				}
			}

			if (prev_time_remaining != time_remaining) {
				fprintf(stderr, "%s - paused\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
				prev_time_remaining = time_remaining;
			}
		}

		else if (state == STATE_FINISH) {
			static int reverse = 1;
			if (reverse == 1) {
				fprintf(stderr, "%%{R}%s%%{R}\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
				reverse = 0;
			}
			else {
				fprintf(stderr, "%%{F-}%s\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
				reverse = 1;
			}

			if (cmd == CMD_START || cmd == CMD_PAUSE || cmd == CMD_RESET) {
				state = STATE_INIT;
				sleepreq.tv_nsec = DEFAULT_SLEEP_TIME_NS;
				fprintf(stderr, "%s\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
			}
		}

		else if (state == STATE_CHANGE_UNIT) {
			if (cmd == CMD_PAUSE)
				state = STATE_INIT;
			else if (cmd == CMD_INCREASE)
				step += 1;
			else if (cmd == CMD_DECREASE && step > 0)
				step -= 1;
			else if (cmd == CMD_CHANGE_UNIT) {
				state = STATE_INIT;
				fprintf(stderr, "%s\n", print_timer(time_remaining, timerstr, TIMER_STR_SIZE));
			}
			else if (cmd == CMD_NEXT_UNIT) {
				switch (units) {
				case UNITS_SEC: units = UNITS_MIN; break;
				case UNITS_MIN: units = UNITS_HOR; break;
				case UNITS_HOR: units = UNITS_SEC; break;
				}
			}

			char unitsch = units == UNITS_MIN ? 'm' : (units == UNITS_SEC ? 's' : 'h');
			fprintf(stderr, "%d%c\n", step, unitsch);
		}

		cmd = CMD_NONE;
		nanosleep(&sleepreq, 0);
	}

	return 0;
}
