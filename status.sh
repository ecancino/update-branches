source "$(dirname -- ${0})/colors.sh"

# EXIT STATUS
function st {
  if [ "$@" -eq "0" ]; then 
    echo -e " [${Green}SUCCESS${Reset}] "; 
  else 
    echo -e " [${Red}ERROR${Reset}] "; 
    exit "$@";
  fi
} 
