#!/bin/bash 
#
# Migrate a Snips skill to the v2.0 framework
#
# (c) A. Dominik, may 2019
#

# ask user for skill name:
#
echo "Give your new skill a name."
echo "The name must be an existing skill with up-to-date GitHub repo."
echo "The migratted version will be stored in the current work-dir."
echo "The ole version of teh skill will be stored in a new directory <name>-v1.0"
read -p "Name of the new skill [myNewJuliaSkill]: " SKILLNAME
SKILLNAME="${SKILLNAME:-myNewJuliaSkill}"

echo ""
if [[ -z $SKILLNAME ]] ; then
  echo "ERROR: The skill name is required!"
  exit 1
elif [[ "$SKILLNAME" =~ ' ' ]] ; then
  echo "ERROR: The name must not contain whitespace!"
  exit 2
fi

read -p "Your GitHub username [andreasdominik]: " USERNAME
USERNAME="${USERNAME:-andreasdominik}"

# ger from github, if dir not exists:
#
if ! [[ -d $SKILLNAME ]] ; then
  git clone git@github.com:andreasdominik/${SKILLNAME}.git
fi
mv $SKILLNAME ${SKILLNAME}-v1.0

# rename and create new skill
#
git clone git@github.com:andreasdominik/ADoSnipsTemplate.git

# change the remote for the new projekct:
#
cp -r ADoSnipsTemplate $SKILLNAME
cd $SKILLNAME
git remote set-url origin git@github.com:${USERNAME}/${SKILLNAME}.git

# modify code:
#  - change name of module
#  - import new module
#  - rename loader function
#
sed "s/module ADoSnipsTemplate/module ${SKILLNAME}/" Skill/ADoSnipsTemplate.jl > Skill/${SKILLNAME}.jl
rm -f Skill/ADoSnipsTemplate.jl

sed "s+/Skill/ADoSnipsTemplate.jl+/Skill/${SKILLNAME}.jl+" loader-ADoSnipsTemplate.jl |
sed    "s+import Main.ADoSnipsTemplate+import Main.${SKILLNAME}+" |
sed    "s+ADoSnipsTemplate.getIntentActions()+${SKILLNAME}.getIntentActions()+" > loader-${SKILLNAME}.jl
rm loader-ADoSnipsTemplate.jl


# copy source code from old skill:
#
cd ..
cp -f ${SKILLNAME}-v1.0/config.ini ${SKILLNAME}/
cp -f ${SKILLNAME}-v1.0/Skill/* ${SKILLNAME}/Skill/

rm ${SKILLNAME}/Skill/callback.jl
rm ${SKILLNAME}/Skill/Skill.jl

cd $SKILLNAME
echo "The GitHub repository is:"
echo "$GIT_REMOTE"
git status

echo "You're done!"
echo "Change to $SKILLDIR/$SKILLNAME and add the action code to your skill!"
