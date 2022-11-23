resource "aws_lb" "alb" {
    create_lb = var.create_lb

    name = "alb-my"
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = [for subnet in aws_subnet.public_subnet: subnet.id]

    tags = {
    Environment = "production"
    Owner = "Amit Kumar"
    ManagedBy = "terraform"
  }
}

resource "aws_lb_target_group" "alb_target_group" {  
  name     = "${var.target_group_name}"  
  port     = "${var.target_group_port}"  
  protocol = "HTTP"  
  vpc_id   = "${var.vpc_id}"   
  tags {    
    name = "${var.target_group_name}"
    Owner = "Amit Kumar"
    ManagedBy = "terraform"    
  }   
  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 1800    
    enabled         = "${var.target_group_sticky_enable}"  
  }   
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "${var.target_group_path}"    
    port                = "${var.target_group_port}"  
  }
}

resource "aws_lb_listener" "alb_listener" {  
  load_balancer_arn = "${aws_lb.alb.arn}"  
  port              = "${var.alb_listener_port}"  
  protocol          = "${var.alb_listener_protocol}"
  
  default_action {    
    target_group_arn = "${aws_lb_target_group.alb_target_group.arn}"
    type             = "forward"  
  }
}
#Instance Attachment
resource "aws_lb_target_group_attachment" "alb_instance_attachment" {
  target_group_arn = "${aws_lb_target_group.alb_target_group.arn}"
  target_id        = var.target_id
  port             = 8080
}


