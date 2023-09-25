alertExit(){
	echo ""
	echo "**************************************************"
	echo " ${bold}$1${normal}"
	echo "**************************************************"
	echo ""
	exit 1
}

alertNotify(){
	echo ""
	echo "=================================================="
	echo " $1"
	echo "=================================================="
	echo ""
}
alertSlack(){
	curl -D zheaders.json -X POST -H 'Content-Type: application/json' -d @z.json https://hooks.slack.com/services/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 > zSlackNotify.json
}