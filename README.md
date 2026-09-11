# hermes-agent

## dependencies
### Required
- k3d (or a k8s cluster of choice)
- kubectl
- helm
- hemlfile

### Optionnal
#### Signal pairing
- qrencode

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
export HERMES_<FINAL_KEY_NAME>
```
Eg, for openrouter models:
```
read -rs HERMES_OPENROUTER_API_KEY
export HERMES_OPENROUTER_API_KEY
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

## Optional features
To enable them run `helmfile sync` with `--state-values-set <feature>.enabled=true`.

You can chain multiple optionnal features together like:
```
helmfile \
    --state-values-set signal.enabled=true \
    --state-values-set matrix.enabled=true \
    --state-values-set ollama.enabled=true \
    sync
```

### Signal
HERMES_SIGNAL_ACCOUNT: Hermes phone number
HERMES_SIGNAL_ALLOWED_USERS: Who doe sHermes respond to (comma separated list)
```
read -r HERMES_SIGNAL_ACCOUNT
export HERMES_SIGNAL_ACCOUNT
```
```
read -r HERMES_SIGNAL_ALLOWED_USERS
export HERMES_SIGNAL_ALLOWED_USERS
```
```
helmfile --state-values-set signal.enabled=true sync
```
then pair the account that has the phone number you chose:
```
./scripts/pair_signal.sh
```