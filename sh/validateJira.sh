while getopts "c:" opt
do
	case "$opt" in
		c ) circleCi="$OPTARG" ;;
	esac
done

echo "i got this far 1"

echo "$currentTerminalPath"
if [ "${circleCi}" == true ]; then
	git pull --rebase origin "$CIRCLE_BRANCH"
	currentTerminalPath=$(pwd)
	ls -R
fi

#Initialize alert functions
source ./sh/alert.sh

echo "i got this far 2"

alertSection -a "Validating Branch Name starts with a Valid Jira Ticket" -l "start" -b false
#retrieve branch name
#branch=$(git branch --show-current)
branch="test-123.1" #branch value for testing

echo "i got this far 3"

#validate that branch name has required characters to be a Jira Ticket
if [[ "$branch" != *"-"* ]] || [[ ! "$branch" =~ [0-9] ]]; then
	alertExit -a "Invalid branch name ${branch}. \n Branch name must start with valid Jira Ticket number (including project key prefix). \n example: KEY-0123" -b false
fi

echo "i got this far 4"

#get ticket number from branch name
projectKey=$(echo $branch| cut -d'-' -f 1)
issueNumber=$(echo $branch | sed -r 's/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/')
jiraTicket="$projectKey-$issueNumber"
alertNotify -a "Branch Name: $branch \n Jira Ticket from Branch Name: $jiraTicket" -b false

#http request to Jira api to validate jiraTicket is valid


alertSection -a "Validating Branch Name starts with a Valid Jira Ticket" -l "end" -b false

