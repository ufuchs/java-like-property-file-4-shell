Instead of forcing the users of a shell script to manipulate/adjust the content of one of your shell scripts for his/her own needs you can separate this concerns into a Java-like property file.

There are two scripts.

'properties.sh' is the essential one.

It provides the functionality to read the prop file and getting a value by key.

The second one, 'propertiesCheck.sh', is intended for checking the integrity of your prop file.

Using this script is optional.

In the 'application' directory you will find a demo to demonstrate the functionality.

It wraps the 'tar' command parametrised by the prop file.

(Background : The whole thing was created to establish a backup strategy for a multiple project Eclipse/Osgi application to archive some of sub projects for a later reuse by other persons. Outside any git repository.)

BE AWARE:

Just now I detected an error in properties like this: 

  "tar-extra-options=--exclude-tag=exclude.tar"

It gets you a value of "exclude.tar" instead of "--exclude-tag=exclude.tar". Sorry.

Best regards, Uli

 
 
