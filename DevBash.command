#!/bin/bash
# Created by Elie Kassouf
# December 25th, 2019



##### CONFIGURATION #####

# Enable xpg_echo (allows escape-sequences with \n)
shopt -s xpg_echo

# Text Color NC = No Color
# https://stackoverflow.com/questions/5947742/
greenC='\033[1;32m'
nC='\033[0m'

# Emojis to add some color to the script
blueArrow="➡️  "
blueInfo="ℹ️  "
greenCheck="✅ "
redCross="❌ "
whiteQuestion="❔ "
redDoubleEx="‼️ "

##### CONFIGURATION #####








##### START OF HOMEBREW #####

# Need to make sure homebrew is properly configured because
#  our development environments require it and some of its packages


# Postgres and Cask are required to setup my environment.
# Setup your own required flags here
postgresInstalled=false
caskInstalled=false
caskTapped=false



# Function to update brew we will have to use later
homebrewUpdated=false
updateHomebrew () {

    # Don't run if it already has
    if [[ $homebrewUpdated = false ]] ; then
        echo "${blueArrow}Running Homebrew update and doctor before installing package: ${1}"
        brew update
        brew doctor
        echo "${greenCheck}Homebrew update and doctor complete!"
        homebrewUpdated=true
    fi
}





# Function to setup homebrew packages after they are installed
setupHomebrewPackage() {

    # Setup Cask (Will be used to install GUI Apps after homebrew packages are installed first)
    if [[ $1 == "cask" ]]; then
        
        echo "${blueArrow}Setting up cask. -> Tapping the Caskroom/Cask repository from Github using HTTPS."
        brew tap caskroom/cask
        caskTapped=true
        caskInstalled=true
        echo "${greenCheck}Cask is now setup!"
    
     # Setup default postgres database
    elif [[ $1 == "postgresql" ]]; then
        
        echo "${blueArrow}Setting up postgresql..."
        echo "${blueArrow}Starting postgresql..."
        
        # Restart postgres
        brew services restart postgres
        
        postgresVersion=`postgres -V`
        
        echo "${blueInfo}Postgres version: ${postgresVersion}"
        
        # Create new database table
        echo "${blueArrow}Initializing new database 'postgres'..."
        initdb /usr/local/var/postgres -E utf8
        
        # TODO: allow this script to create the default user and pass for the db
        
        # Shutdown db
        brew services stop postgres
        
        postgresInstalled=true;
        
        # Complete
        echo "${greenCheck}Postgresql setup!\n${redDoubleEx}Don't forget to setup a user and password if you haven't already done so${redDoubleEx}"
    
    else
        echo "${blueInfo}${1} does NOT require setup! -> Skipping!"
    fi
}




echo "\n${blueArrow}Verifying prerequisites..."



# Check if homebrew exists and install it if it doesn't
echo "\n${blueArrow}Checking if Homebrew is installed..."
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    echo "${redCross}Homebrew is NOT installed!"
    echo "${blueArrow}Installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo "${greenCheck}Homebrew is installed!\n"
else
    echo "${greenCheck}Homebrew is already installed!\n"
fi


# Install the required packages if they don't exist
echo "${blueArrow}Checking if required homebrew packages are installed\n"

# Required packages array.
# Add packages to the list.
# Make sure packages are on a newline or seperated by a space
requiredHomebrewPackages=(
"cask"
"postgresql"
"geoip"
"wget"
"jenv"
"heroku"
"python"
"sbt"
"imagemagick"
)


# Iterate and check if the package exists -> if not -> install it!
homebrewPackageExists=false
for i in "${requiredHomebrewPackages[@]}"; do
    
   if brew ls --versions $i > /dev/null; then
     echo "${greenCheck}${i} is already installed!"
     homebrewPackageExists=true
     
     # Check if cask and postgres are installed and set flag.
     # Will be required later
     if [[ $i == "cask" ]]; then
        caskInstalled=true
     elif [[ $i == "postgresql" ]]; then
        postgresInstalled=true
     fi
     
   else
     echo "${redCross}${i} is NOT installed!"
     echo "${blueArrow}Installing ${i}..."
     updateHomebrew "${i}"
     brew install ${i}
     setupHomebrewPackage "${i}"
     echo "${greenCheck}${i} is now installed!"
   fi
   
done


# If at least one package exists prompt the user if they want to update
homebrewUpgraded=false
if [[ $homebrewPackageExists = true ]]; then
    
    outdatedBrewPackages=`brew outdated`
    
    if [ -z "$outdatedBrewPackages" ]; then
        echo "\n${greenCheck}Homebrew upgrade not required. -> All packages are up to date!\n"
    else
        # Propmt the user if they want to upgrade
        echo "\n${blueInfo}One or more homebrew packages require an update:\n${outdatedBrewPackages}\n"
        read -n1 -p "${whiteQuestion}Run Homebrew Upgrade? [Y/n] " userBrewUpgradeInput
        echo "\n"
        
        if [[ $userBrewUpgradeInput =~ ^[Yy]$ ]]; then
            echo "\n${blueArrow}Upgrading Homebrew..."
            brew upgrade
            homebrewUpgraded=true
            echo "${greenCheck}Homebrew upgrade completed."
        fi
    fi
fi


if [[ $caskInstalled = true ]]; then
    
    echo "${blueArrow}Homebrew cask is intalled. -> Verifying required casks...\n"
    
    # Requires Cask to be installed (see requiredHomebrewPackages above ^)
    requiresHomebrewCasks=(
    "alfred"
    "expressvpn"
    "iterm2"
    "lastpass"
    "vlc"
    "db-browser-for-sqlite"
    "grammarly"
    "jetbrains-toolbox"
    "slack"
    )




    # Iterate and check if the cask exists -> if not -> install it!
    for i in "${requiresHomebrewCasks[@]}"; do
        
       if brew cask ls --versions $i > /dev/null; then
         echo "${greenCheck}${i} cask is already installed!"
       else
       
         echo "${redCross}${i} is NOT installed!"
         
         # Tap caskroom/cask if not done already
         if [[ $caskTapped = false ]]; then
            echo "${blueArrow}Tapping the Caskroom/Cask repository from Github using HTTPS."
            brew tap caskroom/cask
            caskTapped=true
            echo "${greenCheck}Tapping successful!"
         fi
         
         echo "${blueArrow}Installing cask: ${i}..."
         brew cask install ${i}
         echo "${greenCheck}${i} cask is now installed!"
       fi
       
    done
    
else
    echo "${blueArrow}Homebrew cask is NOT intalled. -> Skipping cask verification and install"
fi



echo "\n"



# If homebrew was updated, run cleanup!
if [[ $homebrewUpdated = true ]] || [[ $homebrewUpgraded = true ]] ; then
    echo "\n${blueArrow}Cleaning up homebrew..."
    brew cleanup
    echo "${greenCheck}Homebrew cleanup completed.\n\n"
fi


##### END OF HOMEBREW #####







##### START OF USER GREETING #####


# Greet the user with a custom greeting
timeOfDay=`date +%H`

# Fixes error with 08
# https://stackoverflow.com/a/37092657
timeOfDay=`expr $timeOfDay + 0`

if [[ $timeOfDay -lt 12 ]]; then
    echo -e "Good morning ${greenC}${USER}${nC}!"
elif [[ $timeOfDay -lt 18 ]]; then
    echo -e "Good afternoon ${greenC}${USER}${nC}!"
else
    echo -e "Good evening ${greenC}${USER}${nC}!"
fi

echo "What are you working on this fine day?\n"

##### END OF USER GREETING #####







##### START OF ENVIRONMENT SETUP ######

# TODO: Clean up this section. Options below should be stored in a array. Seems like a lot of repetitive code..


# Here we can take advantage of starting specific services and
#  setting up the required environment the user wants to work within.


# Configure the selectable environments to prompt
envA='Project 1 (API)'
envB='Project 1 (APP)'
envC='Project 1 (APP and API)'
envD='Project 2'
envE='Upgrade all casks (--greedy) *use cautiously*'


promptEnvironmentSelection () {
    
    # Display the selectable environments
    echo "a) ${envA}"
    echo "b) ${envB}"
    echo "c) ${envC}"
    echo "d) ${envD}"
    echo "e) ${envE}"
    echo "\n${blueInfo}'x' will exit this process\n"

    # Prompting: -p and specifying 1-character-input -n1 allows to insert option without ENTER key.
    read -n1 -p "${whiteQuestion}Option: " userEnvironmentInput

    # Add a line break to make it visually pleasing
    echo "\n"




    # All environments require postgres running so make sure it's up and running
    if [[ $userEnvironmentInput =~ ^[AaBbCcDd]$ ]]; then
        
        if [[ $postgresInstalled = true ]] ; then
            echo "${blueArrow}Firing up postgresql..."
            brew services restart postgres
            echo "${greenCheck}Postgres is up and running!\n"
        else
            echo "${redCross}ERROR! -> Postgres is NOT installed!\n"
        fi
    fi




    # Check what environement the user wants to setup
    if [[ $userEnvironmentInput =~ ^[Aa]$ ]]; then

        echo "${blueArrow}Setting up environment for: ${envA}...\n"
        
        echo "\n${blueArrow}Opening required applications..."
        open "/Applications/Google Chrome.app"
        
        # TODO: There needs to be a better way to open IntellIJ for now replace '193.5662.53' with your own version number
        # Note: JetBrains keeps 2 copies of the IDE if installed via toolbox so you can easily roll back.
        #       You can specify the previous version below as well if required
        cd ~/Library/Application\ Support/JetBrains/Toolbox/apps/IDEA-U/ch-0/193.5662.53/ && open "IntelliJ IDEA.app"
        
        
        echo "\n${greenCheck}Environment for: ${envA} is now setup.\n${blueArrow}Please review the log above for other details"
        
        
        # Launch Iterm and Open a new tab with a predefined profile
        # In this case this will auto launch my web service
        #osascript -e 'tell application "iTerm"' -e 'activate' -e 'tell current window to set tb to create tab with profile "Project 1 (API) LOCALHOST"' -e 'end tell';

        # Launch NGROK Profile in iTerm to make my web service open to the public over HTTPS
        #osascript -e 'tell application "iTerm"' -e 'activate' -e 'tell current window to set tb to create tab with profile "Project 1 (API) NGROK"' -e 'end tell';
        
    elif [[ $userEnvironmentInput =~ ^[Bb]$ ]]; then

        echo "${blueArrow}Setting up environment for: ${envB}...\n"
        
        echo "\n${blueArrow}Opening required applications..."
        open "/Applications/Atom.app"
        open "/Applications/Google Chrome.app"
        open "/Applications/Dash.app"
        
        # Launch Iterm and Open a new tab with a predefined profile
        # In this case this will auto launch my web service
        #osascript -e 'tell application "iTerm"' -e 'activate' -e 'tell current window to set tb to create tab with profile "Project 1 (API) LOCALHOST"' -e 'end tell';

        # Launch NGROK Profile in iTerm to make my web service open to the public over HTTPS
        #osascript -e 'tell application "iTerm"' -e 'activate' -e 'tell current window to set tb to create tab with profile "Project 1 (API) NGROK"' -e 'end tell';
        
        
        echo "\n${greenCheck}Environment for: ${envB} is now setup.\n${blueArrow}Please review the log above for other details"
        
    elif [[ $userEnvironmentInput =~ ^[Cc]$ ]]; then

        echo "${blueArrow}Setting up environment for: ${envC}...\n"
        
        echo "\n${blueArrow}Opening required applications..."
        open "/Applications/Atom.app"
        open "/Applications/Google Chrome.app"
        open "/Applications/Dash.app"
        cd ~/Library/Application\ Support/JetBrains/Toolbox/apps/IDEA-U/ch-0/193.5662.53/ && open "IntelliJ IDEA.app"
        
        
        # Launch Iterm and Open a new tab with a predefined profile
        # In this case this will auto launch my web service
        #osascript -e 'tell application "iTerm"' -e 'activate' -e 'tell current window to set tb to create tab with profile "Project 1 (API) LOCALHOST"' -e 'end tell';

        # Launch NGROK Profile in iTerm to make my web service open to the public over HTTPS
        #osascript -e 'tell application "iTerm"' -e 'activate' -e 'tell current window to set tb to create tab with profile "Project 1 (API) NGROK"' -e 'end tell';
        
        
        echo "\n${greenCheck}Environment for: ${envC} is now setup.\n${blueArrow}Please review the log above for other details"
        
    elif [[ $userEnvironmentInput =~ ^[Dd]$ ]]; then

        echo "${blueArrow}Setting up environment for: ${envD}...\n"
        
        echo "\n${blueArrow}Opening required applications..."
        open "/Applications/iTerm.app"
        open "/Applications/Google Chrome.app"
        cd ~/Library/Application\ Support/JetBrains/Toolbox/apps/IDEA-U/ch-0/193.5662.53/ && open "IntelliJ IDEA.app"
        
        
        # Launch Iterm and Open a new tab with a predefined profile
        # In this case this will auto launch my web service
        #osascript -e 'tell application "iTerm"' -e 'activate' -e 'tell current window to set tb to create tab with profile "Project 1 (API) LOCALHOST"' -e 'end tell';

        # Launch NGROK Profile in iTerm to make my web service open to the public over HTTPS
        #osascript -e 'tell application "iTerm"' -e 'activate' -e 'tell current window to set tb to create tab with profile "Project 1 (API) NGROK"' -e 'end tell';
        
        
        echo "\n${greenCheck}Environment for: ${envD} is now setup.\n${blueArrow}Please review the log above for other details"
    
    elif [[ $userEnvironmentInput =~ ^[Ee]$ ]]; then
        
        #Upgrade
        echo "${blueArrow}Upgrading all casks..."
        
        #https://apple.stackexchange.com/a/326894
        brew cask upgrade --greedy
        
        echo "${greenCheck}Upgraded all casks!.\n"
        
        # Re-prompt the user
        promptEnvironmentSelection
        
    elif [[ $userEnvironmentInput =~ ^[Xx]$ ]]; then
        echo "Exiting...\n"
    else
        echo "${redCross}${userEnvironmentInput} is not a valid entry. Please try again...\n"
        
        # Re-prompt the user
        promptEnvironmentSelection
    fi
    
}

# Prompt the user
promptEnvironmentSelection



##### END OF ENVIRONMENT SETUP ######





# Allow the terminal to close itself after completion
#osascript -e 'tell app "Terminal"' -e 'close (every window whose name contains ".command")' -e 'if number of windows = 0 then quit' -e 'end tell' & exit;
