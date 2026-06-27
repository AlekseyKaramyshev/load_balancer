output "image_url" {
  description = "Direct URL to the image in S3 bucket"
  value       = "https://${yandex_storage_bucket.s3-bucket.bucket_domain_name}/${yandex_storage_object.s3-image.key}"
}

output "website_url" {
  description = "URL to access the website via load balancer"
  value = "http://${[
    for listener in yandex_lb_network_load_balancer.yc_nlb.listener :
    [
      for spec in listener.external_address_spec :
      spec.address
    ][0]
    if listener.name == var.lb_listener_name
  ][0]}"
}

output "lb_ip" {
  description = "Load balancer IP address"
  value = [
    for listener in yandex_lb_network_load_balancer.yc_nlb.listener :
    [
      for spec in listener.external_address_spec :
      spec.address
    ][0]
    if listener.name == var.lb_listener_name
  ][0]
}
