# Virtual MFA token, just give it the secret
if hash oathtool &> /dev/null; then
  function mmfa() {
    oathtool --base32 --totp "$1"
  }

  export -f mmfa
fi
