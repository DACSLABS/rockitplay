<a href="https://www.rockitplay.com"><img src="https://public.cloud.rockitplay.com/doc/faststart.png" width="400" /></a>

* [About](#about)
* [ROCKITPLAY Cloud Service](#rockitplay-cloud-service)
   * [External Cloud Services and Dependencies](#external-cloud-services-and-dependencies)
* [Usage](#usage)
* [Deployment](#deployment)
* [Contact](#contact)

# About

Modern video games can easily be as large as 50 GB or even 100 GB. Downloading
such applications even with fast internet connections may take several hours.
A game can only be launched on the local PC once the download is complete and
installation has finished which takes additional time.

**ROCKITPLAY FastStart** is a progressive download technology that launches a game
after downloading only a small fraction of the whole package (Preload). Depending on
the game and the available network connection this preload may be on the order of
only a few percent. While the game can be launched within seconds or minutes with
ROCKIT, the download continues in the background until the entire title is locally
available.

**ROCKIT can be applied to any game.** It is not necessary to modify the game's source
code. This is accomplished by resequencing the download data stream according to the
expected loading order of the game. This sorting order is obtained by monitoring the
loading behavior during actual gameplay sessions from multiple users, e.g., during
QA or alpha/beta test phases. Each gameplay session generates a unique trace file
describing the individual loading sequence. The more individual traces the more
accurate the resequencing order. Trace files can be obtained from multiple users on
multiple PCs using multiple game sessions.

**Machine Learning.** By using machine learning algorithms an optimized sequence of the data stream can be
computed from the set of generated trace files. Together with the traced timing
information a load profile can be created which is used to calculate a user specific
application start point within the data stream. Depending on the game title typically
a few ten traces suffice to obtain a suitable load profile with significant
acceleration factors. Hundreds or more traces will further improve the load profile.
The obtained optimized sequence of the data stream is used to launch the game before
the download is completed. The ROCKIT preload size is dynamically evaluated from both
the load profile of the game and the current download bandwidth measured on the user
side. Statistical fluctuations of the network connection are taken into account.
Faster network connections allow for launching a game with smaller preloads. ROCKIT's data stream representation allows for computing very small patch sizes
compared to conventional general-purpose patch methods.

**Performance.** Once a game is fully downloaded ROCKIT can exploit the sequenced ROCKIT image data
order to accelerate all subsequent game starts. In contrast to a native installation,
ROCKIT's images are defragmented with respect to the loading behavior. Furthermore,
application specific data prefetching can be applied. Even on PCs with
low-performance spinning HDDs read performances equivalent to (or even higher than)
SSD are possible, compared to the native installation.

**ROCKITPLAY FastStart** consists of

* a client-side component (provided as **ROCKIT SDK** or **ROCKIT StreamInstaller**) and
* the service-side component **ROCKITPLAY Cloud Service**.

This repository hosts the **ROCKITPLAY Cloud Service**.

Learn more about **ROCKITPLAY FastStart**: Contact [DACSLABS](https://www.dacslabs.com).  
<a href="https://www.linkedin.com/in/frank-schwarz-rockit/recent-activity/all/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" height="20px"/></a><a href="https://www.youtube.com/@dacslaboratories3117/videos"><img src="https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white" height="20px"/></a>



# ROCKITPLAY Cloud Service

**ROCKITPLAY Cloud Service** is organized in two parts **ROCKIT Edge** and
**ROCKIT Engine**.

Both components are easy to deploy on the [Oracle Cloud Infrastructure](https://www.oracle.com/cloud) (OCI)
using OCI Stacks.

The **ROCKIT Edge** service

* distributes ROCKIT images and ROCKIT patch files to CDN origins,
* accepts ROCKIT trace uploads from game launchers, and
* triggers ROCKIT image processing depending on the collected ROCKIT traces.


The **ROCKIT Engine** is managing the compute part of ROCKITPLAY. It fully
automatically
* converts native game builds to ROCKIT images,
* computes patches between game builds, and
optimizes the ROCKIT-experience by incorporating ROCKIT Trace data into new
ROCKIT images.

The **ROCKIT Engine** is managed by the **ROCKIT Edge** instance(s).
After the initial deployment no further interaction is required.

## External Cloud Services and Dependencies
<a href="https://www.oracle.com/cloud"><img src="https://img.shields.io/badge/Oracle-F80000?style=for-the-badge&logo=Oracle&logoColor=white" height="20px" /></a><a href="https://www.mongodb.com/atlas"><img src="https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white" height="20px" /></a><a href="https://www.slack.com"><img src="https://img.shields.io/badge/Slack-4A154B?style=for-the-badge&logo=slack&logoColor=white" height="20px" /></a>

In order to deploy the ROCKIT Edge and ROCKIT Engine services the following prerequisites have to be met:

1. [Oracle Cloud Infrastructure](https://www.oracle.com/cloud)  
   $${\color{red}\rm{required:}}$$ provides compute and internal block and object storage resources for the **ROCKITPLAY Cloud Service instances**.
2. [MongoDB Atlas](https://www.mongodb.com/atlas)  
   $${\color{red}\rm{required:}}$$ distributed NoSQL database used for internal data management.
3. [Slack](https://slack.com) Workspace  
   $${\color{red}\rm{required:}}$$ ROCKITPLAY Cloud Services posts notifications to various Slack channels.
4. CDN Origin(s)  
   $${\color{red}\rm{required:}}$$ Currently the following origins are supported
   * [Akamai NetStorage](https://www.akamai.com/resources/product-brief/netstorage),
   * S3-compatible object storage services such as
      * [Amazon AWS S3](https://aws.amazon.com/s3/)
      * [Akamai Linode Object Storage](https://www.linode.com/products/object-storage/),
      * [Gcore Object Storage](https://gcore.com/storage), or
      * [OCI Object Storage](https://www.oracle.com/de/cloud/storage/object-storage/).
5. Wildcard SSL Certificate  
   $${\color{green}\rm{optional:}}$$ If available, the endpoints of the ROCKIT Edge and Engine services can follow the companies domain name policy. Alternatively, generic hostname will be provided to access the services.

# Usage

1. Create a new organization:  
   <a href="https://public.cloud.rockitplay.com/doc/rockit-edge-admin-api-v1/index.html#tag/ROCKIT-Edge-Organizations/paths/~1adm~1v1~1orgs/post">![](https://img.shields.io/badge//adm/v1/orgs-lightgray.svg?labelColor=blue&label=POST)</a>
2. Register at least one destination CDN origin:  
   <a href="https://public.cloud.rockitplay.com/doc/rockit-edge-backend-api-v1/index.html#tag/Deployments">![](https://img.shields.io/badge//be/v1/subscriptions-lightgray.svg?labelColor=blue&label=POST)</a>
3. Create a new App:  
   <a href="https://public.cloud.rockitplay.com/doc/rockit-edge-backend-api-v1/index.html#tag/Apps">![](https://img.shields.io/badge//be/v1/apps-lightgray.svg?labelColor=blue&label=POST)</a>
4. Upload native game builds:  
   <a href="https://public.cloud.rockitplay.com/doc/rockit-edge-backend-api-v1/index.html#tag/Apps/paths/~1be~1v1~1builds/post">![](https://img.shields.io/badge//be/v1/subscriptions-lightgray.svg?labelColor=blue&label=POST)</a>
5. The status of the processing can be monitored:  
   <a href="https://public.cloud.rockitplay.com/doc/rockit-edge-backend-api-v1/index.html#tag/Tasks">![](https://img.shields.io/badge//be/v1/tasks-lightgray.svg?labelColor=green&label=GET)</a>
6. As soon as ROCKITPLAY has uploaded the generated ROCKIT image play the game to obtain ROCKIT traces using a game launcher supporting **ROCKITPLAY FastStart**, e.g., **ROCKIT StreamInstaller**.
7. **ROCKITPLAY Cloud Service** automatically optimizes the ROCKIT acceleration and redeploys the new ROCKIT images.

*Additional Information*

* [ROCKIT Edge Administrator Guide](https://public.cloud.rockitplay.com/doc/rockit-edge-admin-api-v1/index.html)
* [ROCKIT Edge Backend API](https://public.cloud.rockitplay.com/doc/rockit-edge-backend-api-v1/index.html)

# Deployment

<a href="https://www.terraform.io"><img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" height="20px"></a>

Please contact [DACSLABS](#contact) to obtain a license for **ROCKITPLAY FastStart**.

> [!NOTE]
> A **ROCKITPLAY Cloud Service** instance can be deployed with a few mouse clicks in less than an hour:


1. Create a MongoDB Atlas account.  
   <details>
      <summary>more...</summary>

      * Sign up for a [MongoDB Atlas account](https://www.mongodb.com/products/platform/atlas-database)
      * During the initial account setup dialog complete "Create a cluster" for Cluster0
      * Set up a payment method
      * Copy the MongoDB Atlas organization ID from the Organization overview page.
      It will be needed when setting up the Base Environment for the ROCKITPLAY Cloud Service.
      * Create a new API key from the Access Manager. The generated public and secret keys will be needed when setting up the Base Environment for the ROCKITPLAY Cloud Service.
   </details>
2. Setup a Slack bot.
   <details>
      <summary>more...</summary>

      * Create a new Slack workspace which will collect logs or simply choose the main workspace.
      * Create a Slack bot  
         (Workspace > Tools & settings > Manage apps > Build > Create an App > From Scratch)

         * use Create a pre-configured app from [here](https://api.slack.com/tutorials/tracks/posting-messages-with-curl) for the new Slack workspace and follow the tutorial
         * copy the Slack token that appears in the tutorial. It will be needed when setting up the Base Environment for the ROCKITPLAY Cloud Service.
      * Create slack channels for collecting info and/or error messages, such as

         * `#info-rockit-edge`,
         * `#info-rockit-engine`,
         * `#error-rockit-edge`, and
         * `#error-rockit-engine`.
      * Test the setup:
         ```
         curl -d "text=Hello World" -d "channel='#info-rockit-edge' -H "Authorization: Bearer <SLACK_TOKEN>" -X POST https://slack.com/api/chat.postMessage
         ```
   </details>
3. Setup your [OCI tenancy](https://www.oracle.com/cloud/).
4. Deploy ROCKITPLAY Base Environment  
   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/DACSLABS/ROCKIT-BaseEnv/archive/refs/heads/prod.zip)  
   In the dialog the following information have to be provided:  
      | Input     | Description |
   |-----|-----|
   | OCI Vault | Use an existing OCI Vault or let ROCKITPLAY setup a new one. |
   | SSL Certificate | Should ROCKITPLAY use an existing enterprise wildcard certifacte or should it provide generic hostnames. |
   | MongoDB Atlas Organization | Identifier of the MongoDB Atlas organization. |
   | MongoDB Atlas keys | Public and secret keys to access the MongoDB Atlas account. |
   | Slack token | Slack bot token to post notifications. |

4. Deploy ROCKITPLAY Cloud Service  
   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/DACSLABS/ROCKITPLAY-dacslabs/archive/refs/heads/prod.zip)  
   The following information are required in the installation dialog:  
   | Input     | Description |
   |-----|-----|
   | DACSLABS Access Link | An access link can be obtained from [DACSLABS](#contact). |
   | ROCKIT Base Link | Copy the `rockit_base_link` value from the latest successul job of the OCI Stack **ROCKIT Base Environment**. |
   | Instance Environment | Select between `prod`, `stage`, and `test` to specify which resource classes will be deployed ranging from free-tier to  production-grade cpnfigurations. |
   | Instance Identifier | Identifier to be used as suffix to all resource names. |
   | MongoDB Atlas Region | MongoDB Atlas home region. |
   | Slack Channels | Name of Slack channels receiving notifications from ROCKITPLAY Cloud Service. |



# Contact

<a href="https://www.dacslabs.com"><img src="https://public.cloud.rockitplay.com/doc/dacslabs.png" width="100" /></a>

DACS Laboratories GmbH  
Niermannsweg 11-15  
40699 Erkrath  
Germany  
info@dacs-labs.com