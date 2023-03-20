# Powershell
A collection of Powershell scripts I've written.

[CompareADGroups-v1.ps1](https://github.com/kadenscroggins/Powershell/blob/main/CompareADGroups-v1.ps1) - Takes two usernames and prints the groups that are present on the first user but absent on the second user. Created to streamline the process of setting up access for new users.

[GetGoogleGroups.ps1](https://github.com/kadenscroggins/Powershell/blob/main/GetGoogleGroups.ps1) - Uses GAM to get a list of all the users from a Google group and writes it to file. Also creates allowlists to ignore users so that they aren't saved. Created to work with an existing script that adds/removes users to a Google group based on an SQL query.

[email-log-search-result-deletion.ps1](https://github.com/kadenscroggins/Powershell/blob/main/email-log-search-result-deletion.ps1) - I used Google Admin to pull a CSV of message IDs from the email reporting tool when we got a bunch of phishing messages that were individual emails. This takes that CSV and converts it to commands to delete messages from users inboxes.

[delete-csv-messages.ps1](https://github.com/kadenscroggins/Powershell/blob/main/delete-csv-messages.ps1) - Looks for a file named `ids.csv` and deletes messages from all users' inboxes, going one message at a time. No headers needed in the file, each line should just be one `rfc822msgid`.

[update-high-storage-users.ps1](https://github.com/kadenscroggins/Powershell/blob/main/update-high-storage-users.ps1) - Pulls users using more than `$quota` MB of storage from Google Workspace via GAM, and adds them to a Google group. Used to warn users about storage quotas being implemented.
