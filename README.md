# Powershell
A collection of Powershell scripts I've written.

[CompareADGroups-v1.ps1](https://github.com/kadenscroggins/Powershell/blob/main/CompareADGroups-v1.ps1) - Takes two usernames and prints the groups that are present on the first user but absent on the second user. Created to streamline the process of setting up access for new users.

[GetGoogleGroups.ps1](https://github.com/kadenscroggins/Powershell/blob/main/GetGoogleGroups.ps1) - Uses GAM to get a list of all the users from a Google group and writes it to file. Also creates allowlists to ignore users so that they aren't saved. Created to work with an existing script that adds/removes users to a Google group based on an SQL query.

[email-log-search-result-deletion.ps1](https://github.com/kadenscroggins/Powershell/blob/main/email-log-search-result-deletion.ps1) - I used Google Admin to pull a CSV of message IDs from the email reporting tool when we got a bunch of phishing messages that were individual emails. This takes that CSV and converts it to commands to delete messages from users inboxes.

[delete-csv-messages.ps1](https://github.com/kadenscroggins/Powershell/blob/main/delete-csv-messages.ps1) - Looks for a file named `ids.csv` and deletes messages from all users' inboxes, going one message at a time. No headers needed in the file, each line should just be one `rfc822msgid`.

[update-high-storage-users.ps1](https://github.com/kadenscroggins/Powershell/blob/main/update-high-storage-users.ps1) - Pulls users using more than `$quota` MB of storage from Google Workspace via GAM, and adds them to a Google group. Used to warn users about storage quotas being implemented.

[inactive-user-warning.ps1](https://github.com/kadenscroggins/Powershell/blob/main/update-inactive-user-warning.ps1) - Takes a list of inactive users on our domain who need to be deactivated, verifies that their accounts still exist in our domain, and adds them to a group for warning them with a GAM command. At the time of writing, >20,000 users were flagged as inactive, but only ~9,000 still had Google Workspace accounts, so I used a hash table to speed up the process that compares existing accounts to inactive users.

[get-users-and-storage.ps1](https://github.com/kadenscroggins/Powershell/blob/main/get-users-and-storage.ps1) - Gets a CSV of all existing Google Workspace users and their storage used via GAM

[ms365](https://github.com/kadenscroggins/Powershell/tree/main/ms365) scripts - A collection of scripts for managing Microsoft 365 licenses for Microsoft Office products. [micorsoft-license-sync.ps1](https://github.com/kadenscroggins/Powershell/blob/main/ms365/microsoft-license-sync.ps1) uses an API key to connect to Microsoft Entra and create accounts, update accounts, and assign licenses based on data from our information systems. [remove-old-licenses.ps1](https://github.com/kadenscroggins/Powershell/blob/main/ms365/remove-old-licenses.ps1) just takes a list of who should have a license and removes licenses for users that shouldn't. [Logger2.ps1](https://github.com/kadenscroggins/Powershell/blob/main/ms365/Logger2.ps1) was an updated drop in replacement for logging that was adapted from some old code written by someone who came before me.
