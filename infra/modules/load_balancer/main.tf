resource "aws_lb" "main" {
  name               = "ilynch-lb"
  subnets            = var.subnet_ids
  security_groups    = [var.lb_security_group_ids]
  load_balancer_type = "application"

  tags = {
    Name = "ilynch-lb"
  }
}

resource "aws_lb_target_group" "main" {
  name        = "lb-app-tg-ilynch"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}


resource "aws_lb_target_group_attachment" "app_attachment" {
  for_each = var.instance_ids # Iterate over instances

  target_group_arn = aws_lb_target_group.main.arn
  target_id        = each.value
  port             = 80

}


output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "dns_name" {
  value = aws_lb.main.dns_name
}