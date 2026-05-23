# terraform/week8/outputs.tf


output "service_url" {

  description = "HTTPS URL of the Cloud Run service"

  value       = google_cloud_run_v2_service.flask_app.uri

}


output "service_name" {

  description = "Cloud Run service name"

  value       = google_cloud_run_v2_service.flask_app.name

}