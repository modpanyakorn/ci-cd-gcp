# project_id = "ci-cd-gcp"
project_id = "adept-bridge-466219-v7" # gcp project id

region = "asia-southeast1"                       # region of vm host
zone   = "asia-southeast1-a"                     # zone of region
image  = "ubuntu-os-cloud/ubuntu-2404-lts-amd64" # define vm image

members = [
  "sampeetiyoo4088@gmail.com",
  "panyakorn.mod@gmail.com"
]

# domain name for forwarding to Load Balance (IAP need HTTPS to access and authenticate)
domains = [
  "pangyaops.dpdns.org",
  "www.pangyaops.dpdns.org",
]

jenkins_sub_domain       = ["jenkins.pangyaops.dpdns.org"]
grafana_sub_domain       = ["grafana.pangyaops.dpdns.org"]
prometheus_sub_domain    = ["prometheus.pangyaops.dpdns.org"]
sonarqube_sub_domain     = ["sonarqube.pangyaops.dpdns.org"]
mongo_express_sub_domain = ["mongo-express.pangyaops.dpdns.org"]
cadvisor_sub_domain      = ["cadvisor.pangyaops.dpdns.org"]

