
# MVX Monitoring Deployer

This repository sets up a monitoring stack using **Prometheus** and **Grafana**. It includes a script to dynamically generate Prometheus scrape configurations based on a `hosts.json` file. 

## Technologies Used

### [Prometheus](https://prometheus.io/)
Prometheus is an open-source systems monitoring and alerting toolkit. It is used to scrape metrics from configured targets at given intervals and provides powerful querying capabilities.

- [Documentation](https://prometheus.io/docs/)

### [Grafana](https://grafana.com/)
Grafana is an open-source platform for monitoring and observability. It enables visualization and analysis of metrics through customizable dashboards.

- [Documentation](https://grafana.com/docs/)

### [Docker Compose](https://docs.docker.com/compose/)
Docker Compose simplifies multi-container Docker applications by defining services, networks, and volumes in a single file.

- [Documentation](https://docs.docker.com/compose/)

### [jq](https://stedolan.github.io/jq/)
jq is a lightweight and flexible command-line JSON processor. It is used in the script to parse and process the `hosts.json` file.

- [Documentation](https://stedolan.github.io/jq/manual/)

---

## Setup Instructions

### Prerequisites
1. Install Docker and Docker Compose:
   - [Install Docker](https://docs.docker.com/get-docker/)
   - [Install Docker Compose](https://docs.docker.com/compose/install/)
2. Install jq for JSON processing:
   ```bash
   sudo apt install jq    # Ubuntu/Debian
   brew install jq        # macOS
   sudo yum install jq    # CentOS/RHEL
   ```

### Directory Structure
Make sure your project directory looks like this:
```
├── Makefile
├── README.md
├── docker-compose.yml
├── generate_config.sh
├── grafana
│   └── provisioning
│       ├── dashboards
│       │   ├── Overview.json
│       │   └── dashboard.yml
│       ├── datasources
│       │   └── datasources.yaml
│       └── grafana.ini
├── hosts.json.example
```

### Configuration

#### 1. Create Hosts Configuration File
- Copy `hosts.json.example` to `hosts.json`:
  ```bash
  cp hosts.json.example hosts.json
  ```

- Edit `hosts.json` to include the servers you want to monitor. Each entry should be a list of `[Name, IP, Category]`. 

**Example `hosts.json.example`:**
```json
[
    ["Admin-Station", "0.0.0.0", "infrastructure"],
    ["Proxy", "1.1.1.1", "infrastructure"],
    ["Mainnet-Validator-A", "2.2.2.2", "mx-node"],
    ["Mainnet-Validator-B", "3.3.3.3", "mx-node"],
    ["Web-Apps", "4.4.4.4", "Apps"]
]
```

### Running the Stack

#### 1. Generate Prometheus Configuration
Run the script to generate the `prometheus.yml` file dynamically:
```bash
make generate
```

#### 2. Start the Stack
Use the following command to start all services (Prometheus, Grafana, and configuration generator):
```bash
make start
```

#### 3. Refresh the Stack
If you make changes to the configuration, use the refresh command to restart the services:
```bash
make refresh
```

---

## Accessing the Services

- **Prometheus**: [http://localhost:9090](http://localhost:9090)
- **Grafana**: [http://localhost:3000](http://localhost:3000)
  - Default credentials:
    - Username: `admin`
    - Password: `admin`

---

## Customization
- Add new dashboards in the `grafana/provisioning/dashboards` directory.
- Add new datasources in `grafana/provisioning/datasources/datasources.yaml`.

---

## Contributions
Feel free to submit issues or contribute to improve this project.

---

## License
This project is licensed under the MIT License.
