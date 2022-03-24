# Learn Nomad - Deploy and Manage Edge Services

This repository is a companion to the [Deploy and Manage Edge Services
](https://learn.hashicorp.com/tutorials/nomad/edge) tutorial, containing configuration files to create a Nomad cluster (3 Nomad servers + 1 Nomad client)in one AWS region and one Nomad client in another region.

This environment emulates an "edge" environment. In this tutorial, you will schedule the HashiCups database and product-api on the primary environment, and the frontend, public-api, and payments-api on the edge environment. In the process, you will learn how Nomad's built-in service discovery and client disconnect functionality enable edge computing.