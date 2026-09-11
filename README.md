# hermes-agent

## dependencies
- k3d (or a k8s cluster of choice)
- kubectl
- helm
- hemlfile

## usage

### Create a k8s cluster
#### if using k3d:
```
k3d cluster create hermes
```

### Prepare the secrets
#### Optional set any keys you want setup in the hermes environement.
```
read -rs HERMES_<FINAL_KEY_NAME>
```
Eg, for openrouter models:
```
read -rs HERMES_OPENROUTER_API_KEY
```

### Apply the infra
```
helmfile sync
```

### connect to hermes
#### Chat
```
./scripts/hermes.sh
```
#### Troubleshooting or management
```
./scripts/hermes_bash.sh
```

## Features
### Web tools
Comes bundled and configured with searxng and crawl4ai

This gives local and non frontier models access to the internet.

### Hermes Profile
#### Navi (default)
see https://github.com/Thaeroon/hermes-profile-navi
