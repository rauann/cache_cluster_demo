output "load_balancer_dns" {
  value = aws_lb.cache_cluster_demo.dns_name
}
