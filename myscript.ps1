$action =0

while($true){

    #menu
    if ($action -eq 0){
        write-host "Hello! this is an interface for AD creation through PowerShell. Please choose from the following what option you preffer:" 
        write-host 1 - "OU creation"
        write-host 2 - "Group creation"
        write-host 3 - "computers via CSV"
        write-host 4 - "Users via CSV"
        write-host 5 - "User removal via CSV"
        write-host 6 - "Computers removal"

        $action = read-host
    } 


    #ou '1'
    if ($action -eq 1){    

         write-host "Let's make an ou!"
         write-host "please enter the path of your ou" "example (OU=Students,DC=PS,DC=local)"
         write-host "if you don't know the path please enter 'no'"
         write-host "for menu please enter -1"

         $ouPlace = Read-host "path"


    #return to menu
    if ($ouPlace -eq -1){
        $action = 0
        continue

    }  

    #default path when 'no'
    if ($ouPlace -eq 'no'){  

         $ouName = read-host "please enter the name of the ou"
         $user = Get-ADOrganizationalUnit -LDAPFilter "(Name=$ouName)"
         $userN = $user.name

    #if name exist
    if ($userN.length -gt 0) {   
        write-host "the ou already exists" -f red
        $action = 1
        continue

    #the name dosn't exist so - creation of ou
    }else {   
             New-ADOrganizationalUnit -name $ouName
             write-host "the ou has been created succesfully" -f green 
             $action = 1
             continue
    } 
    
    
    #(not 'no')
    }  else {   


    #if path exists
    try {

         Get-ADOrganizationalUnit -filter * -searchBase $ouPlace 
         write-host "the ou path exists" -f green

         $ouName = read-host "please enter the name of the ou"
         $user = Get-ADOrganizationalUnit -LDAPFilter "(Name=$ouName)" -SearchBase "$ouPlace"
         $userN = $user.name

            #if name exist
            if ($userN.length -gt 0) {   
                write-host "the ou already exists" -f red
                $action = 1
                continue

      
            } 

            #ou creation
            else {   
                     New-ADOrganizationalUnit -name $ouName -Path $ouPlace
                     write-host "the ou has been created succesfully" -f green
                     $action = 1
                     continue
            } 


        } 


    #the path doesn't exist
    catch {
   
        write-host "the ou path doesn't exist" -f red
        $action = 1
        continue

        } 


    }  


  }  


    #group creation '2'
    if ($action -eq 2){

         write-host "Let's make a group!"
         write-host "please enter the name of the group"
         write-host "for menu please enter -1"

         $grName = Read-host "name"

         write-host "please enter the path of your group. example: (DC=PS,DC=local)"
         write-host "if you don't know the path please enter 'no'"

         $grPlace = Read-host "path"
    


    #return to menu
    if ($grName -eq -1){
        $action = 0
        continue

    } 

    #path is 'no'
    if($grPlace -eq "no"){

        $user = Get-ADGroup -LDAPFilter "(Name=$grName)"
        $userN = $user.name

    #if name exists
    if ($userN.length -gt 0) {   
        write-host "the group already exists" -f red
        $action = 2
        continue

         
    }

    #name doesn't exist so make new group with GS 
    else{

        write-host "please write which GroupScope you choose "
        write-host "DomainLocal"
        write-host "Global"
        write-host "Universal"
        [string] $GS = read-host 

        New-ADGroup $grName -GroupScope "$GS"
        write-host "group has been succesfully created" -f green

    }


    } else {

    #if path exists
    try {

        Get-ADOrganizationalUnit  -filter * -searchBase $grPlace

        write-host "ou path exists" -f Green

        $user = Get-ADGroup -LDAPFilter "(Name=$grName)"
        $userN = $user.name

    #if name exists
    if ($userN.length -gt 0) {   
        write-host "the group already exists" -f red
        $action = 2
        continue

         
    }

    #name doesn't exist
    else{

        write-host "please write which GroupScope you choose"
        write-host "DomainLocal"
        write-host "Global"
        write-host "Universal"
        [string] $GS = read-host 

        New-ADGroup -path $grPlace -name $grName -GroupScope $GS

        write-host "new group has been created" -f Green


    }
    }

    #if path doesn't exist
    catch {
        
        write-host "the path doesn't exist" -f red
        $action = 2
        continue


    }




    }



    



}


    #computer c '3'
    if ($action -eq 3){
        
         
         write-host "please enter the path. example: (CN=Computers,DC=PS,DC=local)"
         write-host "for menu please enter -1"

         $Cpath = Read-host "path: "

    #return to menu
    if ($Cpath -eq -1){
        $action = 0
        continue

    }


    try {

        Get-ADOrganizationalUnit  -filter * -searchBase $Cpath

        write-host "the ou path exists" -f Green

        [string] $Fpath = read-host "please enter the path of the computers file"

        try{

            Get-Content -path $Fpath -ErrorAction Stop
            write-host "the file path exists" -f Green
        } 
        catch {

            write-host "the name of the folder was not found" -f Red

        }

        if ($Fpath.Contains(".csv" )){
            
            $computers= Import-Csv -Path "$Fpath" 

            foreach($computer in $computers){

               try{
                    New-ADComputer $computer.name -Path $Cpath

               }
               catch{

               }
            }

            write-host "a new computers list from a csv file has been succesfully created" -f Green


        }

        #c path doesn't contain csv so make a new computer 
        else{

            New-ADComputer -name "$Fpath" -path $Cpath 
            write-host "a new computer has been created" -f Green
        }
    }

    catch {
        
        write-host "the path of the folder was not found" -f Red
        $action = 3
        continue

    }




    }


    #users c '4'
    if ($action -eq 4){
        
         
         write-host "please enter the ou path. example: (CN=Users,DC=PS,DC=local)"
         write-host "for menu please enter -1"

         $OUpath = Read-host "path"

    #return to menu
    if ($OUpath -eq -1){
        $action = 0
        continue

    }


    try {

        #if ou path exists
        Get-ADOrganizationalUnit  -filter * -searchBase $OUpath

        write-host "the ou path exists" -f Green

        [string] $FUpath = read-host "please enter the path of the users file"

        #if file path exists
        try{

            Get-Content -path $FUpath

        } 

        catch {

            write-host "the path of the folder was not found" -f Red

        }

        if ($FUpath.Contains(".csv" )){


            $users= Import-Csv -Path "$FUpath" 

            foreach($user in $users){

               try{
                    New-ADUser $user.name -path $OUpath

               }
               catch{

               }
            }

            write-host "a new users list from a csv file has been succesfully created" -f Green


        }

        #the u path doesn't contain csv  
        else{
            
            New-ADUser -Path $OUpath -name $FUpath
            write-host "a new user has been created" -f Green

        }
    }

    catch {
        
        write-host "the ou path was not found" -f Red
        $action = 4
        continue

    }



}


    #users d '5'
    if ($action -eq 5){
        
         
         write-host "please enter the path. example: (CN=Users,DC=PS,DC=local)"
         write-host "for menu please enter -1"

         $OU1path = Read-host "path: "

    #return to menu
    if ($OU1path -eq -1){
        $action = 0
        continue

    }


    try {

        Get-ADOrganizationalUnit  -filter * -searchBase $OU1path

        write-host "the ou path exists" -f Green

        [string] $FU1path = read-host "please enter the path of the users file"

        #if file path exists
        try{

            Get-Content -path $FU1path
            write-host "the path of the folder exists" -f Green

        } 

        catch {

            write-host "the path of the folder was not found" -f Red

        }


        if ($FU1path.Contains(".csv" )){

            $users1= Import-Csv -Path "$FU1path" 

            foreach($user1 in $users1){

               try{
                    Remove-ADUser $user1.name 

               }
               catch{

               }
            }

            write-host "a users list has been succesfully deleted" -f Green


        }

        #the user path doesn't contain csv  
        else{
            
            #remove user if exists
            try {
                 Get-Content -name $FU1path 
                 Remove-ADUser -name $FU1path 
                 write-host "the user was succesfully removed" -f green
            }
            catch {

                  write-host "the user was not found" -f Red
                  $action = 5
                  continue

            }

        }
    }

    catch {
        
        write-host "the path was not found" -f Red
        $action = 5
        continue

    }
















}


    #computer d '6'
    if ($action -eq 6){
        
         
         write-host "please enter the path. example: (CN=Computers,DC=PS,DC=local)"
         write-host "for menu please enter -1"

         $OU2path = Read-host "path: "

    #return to menu
    if ($OU2path -eq -1){
        $action = 0
        continue

    }


    try {

        Get-ADOrganizationalUnit  -filter * -searchBase $OU2path

        write-host "the ou path exists" -f Green

        [string] $FCpath = read-host "please enter the path of the computers file"


        #if file path exists
        try{

            Get-Content -path $FCpath

            write-host "the folder path exists" -f Green

        } 

        catch {

            write-host "the path of the folder was not found" -f Red

        }



        if ($FCpath.Contains(".csv" )){


            $users2= Import-Csv -Path "$FCpath" 

            foreach($user2 in $users2){

               try{
                    Remove-ADcomputer $user2.name 

               }
               catch{

               }
            }

            write-host "a computers list has been succesfully deleted" -f Green


        }

        #the computer path doesn't contain csv  
        else{
            
            #remove user if exists
            try {
                 Get-Content $FCpath
                 Remove-ADComputer -name $FCpath 
                 write-host "the computer was succesfully removed" -f green
            }
            catch {

                  write-host "the computer was not found" -f Red
                  $action = 6
                  continue

            }

        }
    }

    catch {
        
        write-host "the path was not found" -f Red
        $action = 6
        continue

    }
















}




  
  

}







