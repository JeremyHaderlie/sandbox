#Import Project Variables
source ./sh/.alertVars.sh

bold=$(tput bold)
red=$(tput setaf 1)
magenta=$(tput setaf 5)
green=$(tput setaf 2)
normal=$(tput sgr0)
eq49=$(printf '%.s═' {1..49}; echo "")
d49=$(printf '%.s─' {1..49}; echo "")
d48=$(printf '%.s─' {1..48}; echo "")
dot49=$(printf '%.s┈' {1..49}; echo "")

alertExit(){
	OPTIND=1
	while getopts "b:a:" opt
	do
		case "$opt" in
			b ) boldOn="$OPTARG" ;;
			a ) alert="$OPTARG" ;;
		esac
	done

	if [[ ! -z ${alert} ]]; then
		echo ""
		echo "${red}╒${eq49}${normal}"
		if $boldOn; then echo "${red}├${d49}${normal}"; fi
		if $boldOn; then echo " ${red}${bold}$alert${normal} "
		else echo " ${red}$alert${normal} "; fi
		if $boldOn; then echo "${red}├${d49}${normal}"; fi
		echo "${red}╘${eq49}${normal}"
		echo ""
		exit 1
	fi

}

alertNotify(){
	OPTIND=1
	while getopts "b:a:" opt
	do
		case "$opt" in
			b ) boldOn="$OPTARG" ;;
			a ) alert="$OPTARG" ;;
		esac
	done

	if [[ ! -z ${alert} ]]; then
		echo ""
		echo "${magenta}╒${eq49}${normal}"
		if $boldOn; then echo "${magenta}├${d49}${normal}"; fi
		if $boldOn; then echo " ${bold}$alert${normal} "
		else echo " $alert"; fi
		if $boldOn; then echo "${magenta}├${d49}${normal}"; fi
		echo "${magenta}╘${eq49}${normal}"
		echo ""
	fi

	# Clean up variables and files created durring alert
	unset boldOn
	unset alert
}

alertSection(){
	OPTIND=1
	while getopts "l:a:b:" opt
	do
		case "$opt" in
			l ) location="$OPTARG" ;;
			a ) alert="$OPTARG" ;;
			b ) boldOn="$OPTARG" ;;
		esac
	done

	if [[ ! -z ${location} ]]; then
		if [ "$location" == "start" ]; then
			echo ""
			echo "${bold}${green}╔${eq49}${normal}"
			if $boldOn; then echo "${green}╟${d49}${normal}"; fi
			if $boldOn; then echo "${green}║${normal} ${bold}START $alert${normal} "
			else echo "${green}║${normal} ${bold}START${normal} $alert "; fi
			echo "${green}║${normal}╭${d48}"
			echo "╭╯"
		fi
	fi
	if [ "$location" == "end" ]; then
			echo "╰╮"
			echo "${green}║${normal}╰${d48}"
			if $boldOn; then echo "${green}║${normal} ${bold}END $alert${normal} "
			else echo "${green}║${normal} ${bold}END${normal} $alert "; fi
			if $boldOn; then echo "${green}╟${d49}${normal}"; fi
			echo "${bold}${green}╚${eq49}${normal}"
			echo ""
	fi

	# Clean up variables and files created durring alert
	unset location
	unset alert
	unset boldOn
}

alertEof(){
	tput setaf 3;echo "╔▾▾▾▾▾▾▾▾▾▾▾▾▾▾▾▾╗\n║  ─┬─ ╭──╮ ╷  ╷ ║\n║   │  │  │ ├──┤ ║\n║ ╰─╯  ╰──╯ ╵  ╵ ║\n╚▴▴▴▴▴▴▴▴▴▴▴▴▴▴▴▴╝"; tput sgr0
}

alertSlack(){
	OPTIND=1
	while getopts "c:n:b:i:" opt
	do
		case "$opt" in
			c ) channel="$OPTARG" ;;
			n ) name="$OPTARG" ;;
			b ) body="$OPTARG" ;;
			i ) icon="$OPTARG" ;;
		esac
	done

	#Use inputted variables to modify slack alert template json before sending it.
	if [[ ! -z ${channel} ]]; then echo "channel = $channel"; else channel="$defaultSlackChannel";echo "channel = $channel"; fi
	if [[ ! -z ${name} ]]; then echo "name = $name"; else name="$defaultSlackName";echo "name = $name"; fi
	if [[ ! -z ${body} ]]; then echo "body = $body"; fi
	if [[ ! -z ${icon} ]]; then echo "icon = $icon"; else icon="$defaultSlackIcon";echo "icon = $icon"; fi

	#Update elements of the slack alert template json with inputted parameters.
	slackPostJson="./temp/slackJsonPost.json" #temporary json file name to send to slack.
	updated_json=$(jq --arg new_channel "$channel" --arg new_icon_emoji "$icon" --arg new_username "$name" --arg new_section_text "$body" '
		.channel = $new_channel |
		.icon_emoji = $new_icon_emoji |
		.username = $new_username |
		.blocks[0].text.text = $new_section_text
	' "$SlackTemplateJsonFile")
	
	#create temporary json file to send to slack (file will be deleted in cleanup at the end of the function)
	echo "$updated_json" >> "$slackPostJson"

	# Post alert to slack webhook
	curl \
		-H "Accept: application/json" \
		-H "Content-Type: application/json" \
		-X POST --data "@${slackPostJson}" "${slackWebhookUrl}" \
		#-D ./temp/zheaders.json \
		#> ./temp/alertSlackPostResult.json

	# Clean up variables and files created durring alert
	rm "$slackPostJson" #delete temporary json file that was sent to slack
	unset channel
	unset name
	unset body
	unset icon
}

