# Render the CoreOS cloud-config template file
resource "template_file" "webserver_user_data" {
    template = "${file("${path.module}/templates/webserver_user_data.yml")}"

    vars {
        database = "mysql://dummy:3306"
    }
}

# Configuration for webserver instances
resource "aws_launch_configuration" "webserver" {
    name = "webserver"

    image_id = "${var.aws_coreos_ami}"
    instance_type = "t2.medium"
    key_name = "${var.ssh_key_name}"

    user_data = "${template_file.webserver_user_data.rendered}"

    security_groups = ["${aws_security_group.webserver.id}"]
    associate_public_ip_address = true
}

# Autoscaling group for webserver instances
resource "aws_autoscaling_group" "webserver" {
    # Using the launch config id will force the old ASG version to be destroyed when the launch config user-data changes
    name = "${aws_launch_configuration.webserver.id}-${count.index}"

    count = 3
    vpc_zone_identifier = ["${element(split(",", module.vpc.public_subnets), count.index)}"]

    load_balancers = ["${aws_elb.webserver.name}"]

    min_size = 1
    max_size = 1
    desired_capacity = 1
    health_check_type = "EC2"
    health_check_grace_period = 300
    force_delete = false
    launch_configuration = "${aws_launch_configuration.webserver.name}"

    tag {
        key = "Name"
        value = "webserver"
        propagate_at_launch = true
    }
}

# Firewall for webservers
resource "aws_security_group" "webserver" {
    vpc_id = "${module.vpc.vpc_id}"
    name = "webserver"

    tags {
        Name = "webserver"
    }

    # All traffic from secure site
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.office_subnet}"]
    }

    # HTTP traffic from ELB
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "TCP"
        security_groups = ["${aws_security_group.webserver_elb.id}"]
    }

    # Allow outbound traffic
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
