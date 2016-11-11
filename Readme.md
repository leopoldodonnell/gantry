# Gantry - *A moveable framework to support cloud-container infrastructure*

<img ng-src="/repository/leopoldodonnell/gantry/status?token=" data-title="Container Repository on Quay" src="https://quay.io/repository/leopoldodonnell/gantry/status?token=">


<p align='center'><img align="center" src="gantry.jpg" width="50%" height="50%"></p>

Just like a dockyard gantry, this docker container will help with a lot of the lifting and management of your container-based
infrastructure. A container-based development approach makes sure that your developers and your CI/CD pipeline are using the 
correct tool version with little to no installation head-ache.

This gantry docker image is simple in concept; it has the binaries for a number of tools commonly used in container-base
enterprise infrastructure development. These tools include:

1. [Docker client](https://docs.docker.com/engine/reference/commandline/cli/)
1. [Docker Compose](https://docs.docker.com/compose/reference/)
1. [Hashicorp's packer](https://www.packer.io)
1. [Hashicorp's terraform](https:///www.terraform.io)
1. [Kubernetes kubectl](http://kubernetes.io/docs/user-guide/kubectl-overview/)
1. [Werker's stern](https://github.com/wercker/stern)
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/)

These binaries need credentials and/or access to docker server to do their work, so these are made available to the container 
through volume mounts. Available mounts include the following:

* **/root/.aws** can be mapped to your own aws credentials directory for use with `packer`, `terraform` or `aws cli`
* **/root/.kube** can be mapped to your Kubernetes kubectl config directory
* **/var/run/docker.sock** can be mapped to your host's docker.sock in order to perform docker based commands. This is usseful
from within a docker container context

You can use Gantry as is, or use it as inspiration or bassis for a more opinionated framework.

## Using Gantry

Using gantry only requires that you have a docker client with access to a docker server available from where the gantry container
is run. There is a supplied `bash` script that simplifies most common uses.

From within the gantry root folder...

    > ./gantry

    gantry - a scaffold for building and managing cloud infrastructure without a low installation footprint

    gantry currently offers the following tools:
        - terraform
        - packer
        - kubectl
        - stern
        - docker
        - docker-compose
        - aws cli
    
    To run one of these tools against code in your current directory:
    
    > docker --rm -ti -v /share:/share gantry {toolname tool_args}
    
    Mount points that can be useful to these tools include:
    
      - /root/.aws  to access your AWS credentials
      - /root/.kube to access your Kubernetes kubectl configuration
      - /var/run/docker.sock to share a docker socket for docker commands within the container

Ok, with no arguments you get the help text. So now let's try doing something more interesting.

    > eval $(./gantry aws ecr get-login --region us-east-1 --profile my-profile)
    Flag --email has been deprecated, will be removed in 1.13.
    Login Succeeded

Now you've logged into your AWS ECR registry and you can start pushing/pulling images without having installed the AWS cli


### Gantry in Practice

Running things from a terminal is pretty straight forward, you simply prefix the commands you would have run directly with
the `gantry` script. You do have to be aware that the working directory needs to be shared with gantry and that gantry cannot
*see* other files from your filesystem. If you're using the `gantry` script, it will share your current working directory.

As mentioned above, other files, such as your AWS credentials, are made available by sharing them as volume mounts; you can 
use your default credentials (as is done by the `gantry` script), or you can specify a different path if needed.

Things get interesting when you run gantry from within another docker container such as when a `Jenkins` job is spun up from
the kubernetes plugin. These containers can be kept pretty simple when using `gantry`. As is typical with most Jenkins jobs, 
it begins by pulling files into a workspace. These files then need to be made available to `gantry`.

The Jenkins job is running in a container and gantry is also a container. Both may be mounting the host's docker socket to 
perform docker actions, so existing mounts that are mapped are relative to the host operating system. If you look at the 
`gantry` bash script there is a `-c` option that sets up gantry to handle this.

Here how you address this:

First you make certain that the enclosing container, say the Jenkins executor, has a volume for its workspace directory.

    VOLUMES [ '/workspace' ]

Next gantry get's the container id...

    > cat /proc/self/cgroup |awk -F '/' '$2 = "docker" && NR == 1 {print $NF }'

Then it passes a working directory that should be set to the workspace volume for the enclosing container.

Finally it runs the gantry container with the `--volumes-from` switch with the container id of the executor. This gives 
gantries utilities access to the workspace directory and other volumes so they can function correctly.

## Building Gantry

Gantry is a pretty simple container image that simply installs a few utilities. A build script is provided, but you may also
build it directly from the project root directory.

    > docker build --rm -t gantry .

You can also pass `--build-arg` flags to update the software versions without touching `Dockerfile`.

You will also want to update the `gantry` bash script to use your own **REGISTRY** and put it somewhere on your `PATH`
