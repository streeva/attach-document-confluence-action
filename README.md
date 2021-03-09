# Build Dependencies Report
GitHub Action that locates a Confluence page with a specified title in a specified space and attaches a document to it.  If the page already has an attachment with that filename then the data for that attachment is updated with the nominated local file content which will cause a version increment within Confluence for that attachment.

# Usage

See [action.yml](action.yml)

# Atlassian Access
This action uses the Atlassian RESTful API using OAuth 2.0 (3LO) authorisation type.

* Create an app at the [Atlassian Developer](https://developer.atlassian.com/) site
* Go to *Permissions*, choose Configure for Confluence and make sure the following are added:
  * read:confluence-content.summary
  * write:confluence-file
* Go to *Authorization*, chose Configure for OAuth 2.0 (3LO)
  * Set and copy your **callback URL**
  * Note down your *Authorization URL* if you want
* Go to *Settings*:
  * Copy **Client ID**
  * Copy **Secret**

This action will obtain an access token from a refresh token, to get a refresh token there is a helper script in this repo which you can use to run through the authorisation flow, it requires the the values copied above:
```
./get_access_token <client_id> <secret> <callback_url>
```