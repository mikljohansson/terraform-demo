# Internet facing ELB
resource "aws_elb" "webserver" {
    subnets = ["${split(",", module.vpc.public_subnets)}"]
    security_groups = ["${aws_security_group.webserver_elb.id}"]

    listener {
        instance_port = 8080
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 5
        timeout = 4
        target = "HTTP:8080/"
        interval = 5
    }
}

# Public hostname pointing to ELB
resource "aws_route53_record" "webserver_elb" {
    zone_id = "${var.route53_zone_id}"
    name = "webapp.${var.route53_domain}"
    type = "A"

    alias {
        name = "${aws_elb.webserver.dns_name}"
        zone_id = "${aws_elb.webserver.zone_id}"
        evaluate_target_health = false
    }
}

# Firewall for ELB
resource "aws_security_group" "webserver_elb" {
    vpc_id = "${module.vpc.vpc_id}"
    name = "webserver-elb"

    tags {
        Name = "webserver-elb"
    }

    # HTTP traffic from Gothenburg office
    ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["79.136.49.28/32"]
    }

    # Allow outbound traffic
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
