#!/bin/sh                

#---------- Data Encryption Configuration File ----------

mkdir encryption-configuration-file

cd encryption-configuration-file 

echo "..... Generate an encryption key ....."

	 ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

echo "..... Generate Encryption Configuration File ....."

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

if [ ! -f encryption-config.yaml ]; then
	    echo "Error generating encryption-config"
	        exit -1
fi
