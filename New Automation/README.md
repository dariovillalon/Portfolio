# News-Automation Project #  

Airflow instance that implement the pipelines with extractors of news content from diferent sources:
- Google News.
- Google Alerts.
- Clinical Trials RSS.
- Alphasense (Deprecated).

<br/>

***

## How to run this project:

**1 - Install Docker:**
- Docker Engine and Docker Compose as explainedm [here.](https://docs.docker.com/engine/install/ubuntu/)
- Optionally [manage docker as a non-root user.](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

**2 - Configure environment variables:**
- Copy the sample_dot_env file to (project folder)/.env and replace the content of this file with the 
correct values for this environment.  

**3 - Create and install a Service Account key json file:**
- Copy the json file to (project_folder)/service_account.json.

**4- Build the project:**  
- change dir to (project_folder)/docker/ and then:  

~~~ bash 
docker compose --env-file ../.env build
~~~

~~~ bash
docker compose --env-file ../.env up -d
~~~

***

## How to Deploy a new version:

1 - Teardown the instance. (add -v flag to the following command to clean volumes.)

~~~ bash
docker compose --env-file ../.env down
~~~ 

2 - Pull the changes from remote or copy the new files.

3 - Re-build the images and start the services.

~~~ bash 
docker compose --env-file ../.env build
~~~

~~~ bash
docker compose --env-file ../.env up -d
~~~