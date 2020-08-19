#!/bin/bash
# USAGE: ./create-ldif.sh 100 > users.ldif

NUM=1

echo "# This LDIF file contains examples of groups and users that could be created
# in LDAP when testing. It is not used by the automated tests. The automated
# tests create LDAP groups and users on-the-fly.
#
# Examples here might be useful if you are manually setting up some LDAP entries
# for local development and testing.
dn: ou=TestGroups,dc=owncloud,dc=com
objectclass: top
objectclass: organizationalUnit
ou: TestGroups


dn: ou=TestUsers,dc=owncloud,dc=com
objectclass: top
objectclass: organizationalUnit
ou: TestUsers

"

while [ $NUM -le $1 ]
do
  USERNAME="locust"$NUM
  echo "dn: uid=$USERNAME,ou=TestUsers,dc=owncloud,dc=com
cn: $USERNAME
sn: $USERNAME
displayname: $USERNAME
gecos: $USERNAME
gidnumber: 5000
givenname: $USERNAME
homedirectory: /home/openldap/$USERNAME
loginshell: /bin/bash
mail: $USERNAME@example.org
objectclass: posixAccount
objectclass: inetOrgPerson
uid: $USERNAME
uidnumber: 3000$NUM
userpassword: mero42PWD$NUM

"

  NUM=$[$NUM+1]
done
