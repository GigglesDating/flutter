#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print current branch
echo -e "${YELLOW}Current branch:${NC}"
git branch --show-current

# Add all changes
echo -e "\n${YELLOW}Adding all changes...${NC}"
git add .

# Get commit message
echo -e "\n${YELLOW}Enter commit message (press enter to use 'update'):${NC}"
read commit_msg
if [ -z "$commit_msg" ]; then
    commit_msg="update"
fi

# Commit changes
echo -e "\n${YELLOW}Committing changes...${NC}"
git commit -m "$commit_msg"

# Push to branch
echo -e "\n${YELLOW}Pushing to krishna branch...${NC}"
git push origin krishna

echo -e "\n${GREEN}Done!${NC}" 