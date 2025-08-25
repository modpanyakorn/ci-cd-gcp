# CI/CD in GCP

A project creating CI/CD pipeline in GCP

## In-progress

## Structure

```bash
ci-cd-gcp/
├─ application/
│  ├─ public/
│  │  ├─ public/
│  │  │  ├─ apple-touch-icon.png
│  │  │  ├─ favicon.ico
│  │  │  ├─ index.html
│  │  │  ├─ loader.png
│  │  │  ├─ logo192.png
│  │  │  ├─ logo512.png
│  │  │  ├─ manifest.json
│  │  │  └─ robots.txt
│  │  ├─ src/
│  │  │  ├─ assets/
│  │  │  │  ├─ loader.gif
│  │  │  │  ├─ logo.svg
│  │  │  │  └─ robot.gif
│  │  │  ├─ components/
│  │  │  │  ├─ ChatContainer.jsx
│  │  │  │  ├─ ChatInput.jsx
│  │  │  │  ├─ Contacts.jsx
│  │  │  │  ├─ Logout.jsx
│  │  │  │  ├─ SetAvatar.jsx
│  │  │  │  └─ Welcome.jsx
│  │  │  ├─ pages/
│  │  │  │  ├─ Chat.jsx
│  │  │  │  ├─ Login.jsx
│  │  │  │  └─ Register.jsx
│  │  │  ├─ utils/
│  │  │  │  └─ APIRoutes.js
│  │  │  ├─ App.js
│  │  │  ├─ index.css
│  │  │  └─ index.js
│  │  ├─ .dockerignore
│  │  ├─ .env
│  │  ├─ .gitignore
│  │  ├─ docker-compose-frontend-vm.yml
│  │  ├─ Dockerfile
│  │  ├─ nginx.conf
│  │  ├─ package-lock.json
│  │  ├─ package.json
│  │  ├─ README.md
│  │  └─ yarn.lock
│  ├─ server/
│  │  ├─ controllers/
│  │  │  ├─ messageController.js
│  │  │  └─ userController.js
│  │  ├─ models/
│  │  │  ├─ messageModel.js
│  │  │  └─ userModel.js
│  │  ├─ routes/
│  │  │  ├─ auth.js
│  │  │  └─ messages.js
│  │  ├─ .dockerignore
│  │  ├─ .env
│  │  ├─ docker-compose-backend-vm.yml
│  │  ├─ Dockerfile
│  │  ├─ index.js
│  │  ├─ package-lock.json
│  │  ├─ package.json
│  │  └─ yarn.lock
│  ├─ .gitignore
│  ├─ docker-compose.yml
│  └─ README.md
│
├─ nginx_proxy/
│  ├─ .dockerignore
│  ├─ docker-compose-nginx-proxy-vm.yml
│  └─ nginx.conf
│
├─ db/
│  └─ docker-compose-db-vm.yml
│
├─ devops/
│  ├─ grafana/
│  │  └─ grafana-datasource.yml
│  ├─ prometheus/
│  │  └─ prometheus.yml
│  ├─ docker-compose-devops-vm.yml
│  └─ Dockerfile.jenkins
│
├─ infrastructure/
│  ├─ ansible/
│  │  ├─ collections/
│  │  │  └─ ansible_collections/
│  │  ├─ inventory/
│  │  │  ├─ group_vars/
│  │  │  │  ├─ all.yml
│  │  │  │  ├─ backend.yml
│  │  │  │  ├─ db.yml
│  │  │  │  ├─ devops.yml
│  │  │  │  ├─ frontend.yml
│  │  │  │  └─ nginx_proxy.yml
│  │  │  ├─ hosts.ini
│  │  │  └─ inventory.gcp.yml
│  │  ├─ playbooks/
│  │  │  ├─ 00-bootstrap.yml
│  │  │  ├─ 01-deploy-services.yml
│  │  │  ├─ backend-deploy.yml
│  │  │  ├─ db-deploy.yml
│  │  │  ├─ devops-deploy.yml
│  │  │  ├─ frontend-deploy.yml
│  │  │  ├─ nginx-proxy-deploy.yml
│  │  │  ├─ site.yml
│  │  │  ├─ test.yml
│  │  │  └─ vm_check.yml
│  │  ├─ roles/
│  │  │  ├─ backend/
│  │  │  │  ├─ tasks/
│  │  │  │  │  └─ main.yml
│  │  │  │  └─ templates/
│  │  │  │     ├─ .env.j2
│  │  │  │     └─ docker-compose.yml.j2
│  │  │  ├─ common/
│  │  │  │  └─ tasks/
│  │  │  │     └─ main.yml
│  │  │  ├─ db/
│  │  │  │  ├─ tasks/
│  │  │  │  │  └─ main.yml
│  │  │  │  └─ templates/
│  │  │  │     └─ docker-compose.yml.j2
│  │  │  ├─ devops/
│  │  │  │  ├─ files/
│  │  │  │  │  ├─ grafana/
│  │  │  │  │  │  └─ grafana-datasource.yml
│  │  │  │  │  ├─ jenkins/
│  │  │  │  │  │  └─ Dockerfile.jenkins
│  │  │  │  │  └─ vault/
│  │  │  │  │     └─ vault.hcl
│  │  │  │  ├─ tasks/
│  │  │  │  │  ├─ local-push-secert-to-vault.yml
│  │  │  │  │  ├─ main.yml
│  │  │  │  │  └─ setup-services.yml
│  │  │  │  └─ templates/
│  │  │  │     ├─ .env.j2
│  │  │  │     ├─ docker-compose.yml.j2
│  │  │  │     └─ prometheus.yml.j2
│  │  │  ├─ frontend/
│  │  │  │  ├─ tasks/
│  │  │  │  │  └─ main.yml
│  │  │  │  └─ templates/
│  │  │  │     ├─ .env.j2
│  │  │  │     ├─ docker-compose.yml.j2
│  │  │  │     └─ nginx.conf.j2
│  │  │  └─ nginx_proxy/
│  │  │     ├─ tasks/
│  │  │     │  └─ main.yml
│  │  │     └─ templates/
│  │  │        ├─ docker-compose.yml.j2
│  │  │        └─ nginx.conf.j2
│  │  ├─ templates/
│  │  │  └─ hosts.ini.tftpl
│  │  ├─ ansible.cfg
│  │  ├─ galaxy.yml
│  │  ├─ requirements.yml
│  │  └─ structure.md
│  │
│  ├─ terraform/
│  │  ├─ dev/
│  │  │  ├─ backend.tf
│  │  │  ├─ data.tf
│  │  │  ├─ gcp_account.tf
│  │  │  ├─ load_balance_access_devops_vm.tf
│  │  │  ├─ main.tf
│  │  │  ├─ note.txt
│  │  │  ├─ output_apply.txt
│  │  │  ├─ output_plan.txt
│  │  │  ├─ outputs.tf
│  │  │  ├─ provider.tf
│  │  │  ├─ terraform.tfvars
│  │  │  └─ variables.tf
│  │  ├─ modules/
│  │  │  ├─ compute/
│  │  │  │  ├─ main.tf
│  │  │  │  ├─ outputs.tf
│  │  │  │  └─ variables.tf
│  │  │  └─ network/
│  │  │     ├─ backend_vm.tf
│  │  │     ├─ db_vm.tf
│  │  │     ├─ devops_vm.tf
│  │  │     ├─ frontend_vm.tf
│  │  │     ├─ main.tf
│  │  │     ├─ nginx_vm.tf
│  │  │     ├─ outputs.tf
│  │  │     └─ variables.tf
│  │  ├─ 1.setup-gcp.md
│  │  ├─ 2.setup-variables.md
│  │  └─ 3.build-infra-terraform.md
│  ├─ .env
│  ├─ oauth.json
│  ├─ requirements.txt
│  └─ sa.json
├─ README.md
└─ setup.sh
```
