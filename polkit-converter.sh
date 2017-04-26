#!/bin/sh
# Enable that some programs can be able to run pkexec instead of gksu

## First, it requests the name of the program wanted and then performs
## a query if it exists or not
echo -n 'Please type the name of the program you wish to look: '
read app_name
app_location=$(echo `whereis "$app_name" | awk '{print $2}'`)

## Check if the program the user asks for already exists
## If it doesn't exist, then the program ends
## If the program exist but is not located on /usr/bin, the program ends
## but it gives a warning (should we request user-defined locations?)

is_program_available()
{

  if [ "$app_location" == "" ]; then
    echo "The program you are looking for is not available "
    echo ""
    exit 1
  elif [ 'echo $app_location | grep bin' == "" ]; then
    echo "The program does not have a valid location or may not be valid "
    echo ""
    exit 1
  fi
  return

}
## Check if there is any policy file related to the program wanted
## if any exists then the program is already configured to run pkexec

## The standard location of all polkit policy files is /usr/share/polkit-1/actions/
## so it should't give any issues about wrong directory file
is_policy_available()
{
  cd /usr/share/polkit-1/actions/
  POLKIT_ACTION="org.freedesktop.x.policykit."$app_name".policy"

  if [ -e "$POLKIT_ACTION" ]; then
    echo "This program is already configured "
    echo ""
    exit 1
  fi
  return
}

## Since there is no policy file, we create a generic policy file that allow us to use
## pkexec on the program which is based on the org.freedesktop.policykit.policy file
## Just in case, we switch into the polkit actions directory once again
write_policy_file()
{
  cd /usr/share/polkit-1/actions/
  sudo cp -f org.freedesktop.policykit.policy $POLKIT_ACTION

  ## We required that the user can enter a basic information that will be included on the
  ## polkit action so that the file will have the information needed
  echo -n "Please insert the name of the vendor: "
  read POLKIT_VENDOR
  echo -n "Please insert or paste the url of the vendor: "
  read POLKIT_URL
  echo -n "Please type the description of the action: "
  read POLKIT_DESC
  
  
  ## Complete template of editing the copied file and re-adding once again all of the information,
  ## includes the variables requested on the previous step
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $POLKIT_ACTION
  echo "<!DOCTYPE policyconfig PUBLIC \"-//freedesktop//DTD polkit Policy Configuration 1.0//EN\"" >> $POLKIT_ACTION
  echo "\"http://www.freedesktop.org/software/polkit/policyconfig-1.dtd\">" >> $POLKIT_ACTION
  echo "<policyconfig>" >> $POLKIT_ACTION
  echo "" >> $POLKIT_ACTION
  echo "  <vendor>$POLKIT_VENDOR</vendor>" >> $POLKIT_ACTION
  echo "  <vendor_url>\"$POLKIT_URL\"</vendor_url>" >> $POLKIT_ACTION
  echo "" >> $POLKIT_ACTION
  echo "  <action id=\"org.freedesktop.x.policykit.$app_name\">" >> $POLKIT_ACTION
  echo "    <description>$POLKIT_DESC</description>" >> $POLKIT_ACTION
  echo "    <message>Authentication is required to run a program as another user</message>" >> $POLKIT_ACTION
  echo "    <defaults>" >> $POLKIT_ACTION
  echo "      <allow_any>no</allow_any>" >> $POLKIT_ACTION
  echo "      <allow_inactive>no</allow_inactive>" >> $POLKIT_ACTION
  echo "      <allow_active>auth_admin_keep</allow_active>" >> $POLKIT_ACTION
  echo "    </defaults>" >> $POLKIT_ACTION
  echo "    <annotate key=\"org.freedesktop.policykit.exec.path\">$app_location</annotate>" >> $POLKIT_ACTION
  echo "    <annotate key=\"org.freedesktop.policykit.exec.allow_gui\">true</annotate>" >> $POLKIT_ACTION
  echo "  </action>" >> $POLKIT_ACTION
  echo "" >> $POLKIT_ACTION
  echo "</policyconfig>" >> $POLKIT_ACTION

  return

}

## Create a template named ${app_name}-pkexec which will be the executable file being executed via pkexec
## This step should be fully tested just in case, it doesn't intend to delete or edit the existent binary
## files on /usr/bin but should be handled carefully to prevent major problems
write_polkit_executable()
{
  cd /usr/bin
  app_polkit=$app_name
  app_polkit+="-pkexec"

  echo "#!/bin/sh" > $app_polkit
  echo "pkexec $app_location" >> $app_polkit
  sudo chmod +x $app_polkit

  return
}

is_program_available

is_policy_available

write_policy_file

write_polkit_executable
