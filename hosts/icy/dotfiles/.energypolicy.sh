if [ "$1" = "default" ]; then
	sudo cpupower frequency-set --governor ondemand > /dev/null && \
	sudo cpupower frequency-set --max "4.00GHz" > /dev/null && \
	sudo cpupower set --perf-bias 6 > /dev/null && \
	echo "$1" >> "$XDG_CONFIG_HOME/.energypolicy"

elif [ "$1" = "performance" ]; then
	sudo cpupower frequency-set --governor performance > /dev/null && \
	sudo cpupower frequency-set --max "4.00GHz" > /dev/null && \
	sudo cpupower set --perf-bias 0 > /dev/null && \
	echo "$1" >> "$XDG_CONFIG_HOME/.energypolicy"

elif [ "$1" = "balanced" ]; then
	sudo cpupower frequency-set --governor ondemand > /dev/null && \
	sudo cpupower frequency-set --max "3.30GHz" > /dev/null && \
	sudo cpupower set --perf-bias 9 > /dev/null && \
	echo "$1" >> "$XDG_CONFIG_HOME/.energypolicy"

elif [ "$1" = "powersave" ]; then
	sudo cpupower frequency-set --governor powersave > /dev/null && \
	sudo cpupower frequency-set --max "2.30GHz" > /dev/null && \
	sudo cpupower set --perf-bias 15 > /dev/null && \
	echo "$1" >> "$XDG_CONFIG_HOME/.energypolicy"
fi
