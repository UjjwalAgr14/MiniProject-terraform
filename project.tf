# Terraform Settings Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "~> 3.21" # Optional but recommended in production
    }
  }
}
# Provider Block
provider "aws" {
  profile = "default" # AWS Credentials Profile configured on your local desktop terminal  $HOME/.aws/credentials
  region  = "ap-south-1"
}
# Resource Block

#target group
#resource "aws_lb_target_group" "test" {
 #name     = "Project-tg"
 #port     = 80
  #protocol = "HTTP"

  #health_check {
    #path = "/health"
    #interval = 30
    #timeout = 5
    #healthy_threshold = 2
    #unhealthy_threshold = 5



  #}
#}


#application load balancer
#
  #lb_target_port = 80
  #lb_protocol    = "HTTP"
  #lb_target_type = "instance"
  #lb_listener_port     = 80
  #lb_listener_protocol = "HTTP"
#}
#resource "aws_lb_listener" "test"{

#load_balancer_arn = aws_lb.test.arn
#port = "80"
#protocol = "HTTP"

#default_action {
  #target_group_arn=aws_lb_target_group.test.arn
  #type="forward"
#}  
#}

data "template_file" "user_data" {
  template = <<-EOT
    #!/bin/bash
    sudo yum -y update
    sudo yum -y install ruby
    sudo yum -y install wget
    cd /home/ec2-user
    wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
    sudo chmod +x ./install
    sudo ./install auto
    sudo yum install -y python-pip
    sudo pip install awscli
  EOT
}
resource "aws_launch_template" "this" {
  name          = "Project-tpl"
  image_id      = "ami-07d3a50bd29811cd1"
  instance_type = "t2.micro"
  key_name  = "Jenkins-key" 
  user_data = base64encode(data.template_file.user_data.rendered)
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["sg-0453924d69f5696ae"]
  }
  iam_instance_profile {
    name = "Ec2CodeDeploy"
  }
  
}
#resource "aws_lb_target_group_attachment" "test" {
 # target_group_arn = aws_lb_target_group.test.arn
 # target_id        = aws_autoscaling_group.this.name
 # port             = 80
#}
resource "aws_autoscaling_group" "this" {

  name                      = "Project-asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB" #"ELB" or default EC2
  #availability_zones = var.availability_zones #["us-east-1a"]
  vpc_zone_identifier = ["subnet-0155091a978d9ae85","subnet-02e0964939dfcd36a"]

  

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version #"$Latest"
  }
  
  }
