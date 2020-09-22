if [ "$1" = "default" ]; then
	sudo cpupower frequency-set --governor powersave > /dev/null && \
	sudo cpupower frequency-set --max "3.60GHz" > /dev/null && \
	sudo cpupower set --perf-bias 6 > /dev/null && \
	sudo intel_gpu_frequency --custom max="1050MHz" > /dev/null && \
	echo "$1" >> "$XDG_CONFIG_HOME/.energypolicy"

elif [ "$1" = "performance" ]; then
	sudo cpupower frequency-set --governor performance > /dev/null && \
	sudo cpupower frequency-set --max "3.60GHz" > /dev/null && \
	sudo cpupower set --perf-bias 0 > /dev/null && \
	sudo intel_gpu_frequency --custom max="1050MHz" > /dev/null && \
	echo "$1" >> "$XDG_CONFIG_HOME/.energypolicy"

elif [ "$1" = "balanced" ]; then
	sudo cpupower frequency-set --governor powersave > /dev/null && \
	sudo cpupower frequency-set --max "3.00GHz" > /dev/null && \
	sudo cpupower set --perf-bias 9 > /dev/null && \
	sudo intel_gpu_frequency --custom max="700MHz" > /dev/null && \
	echo "$1" >> "$XDG_CONFIG_HOME/.energypolicy"

elif [ "$1" = "powersave" ]; then
	sudo cpupower frequency-set --governor powersave > /dev/null && \
	sudo cpupower frequency-set --max "1.70GHz" > /dev/null && \
	sudo cpupower set --perf-bias 15 > /dev/null && \
	sudo intel_gpu_frequency --custom max="400MHz" > /dev/null && \
	echo "$1" >> "$XDG_CONFIG_HOME/.energypolicy"
fi
