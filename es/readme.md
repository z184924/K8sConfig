# elastic search

## 无法选取问题

可以尝试注释以下ENV配置

```yaml
            - name: network.publish_host
              value: "$(HOSTNAME).elasticsearch.edu-es.svc.cluster.local"
```

## 设置密码方法

1. 首先启动es

2. 复制nodes.yml到pod内 并进入

```bash
kubectl cp dns.yaml elasticsearch-0:/usr/share/elasticsearch/ -n default
kubectl exec -it elasticsearch-0 -n default -- bash
```

3. 生成证书

```bash
bin/elasticsearch-certutil ca -pem 
unzip elastic-stack-ca.zip
bin/elasticsearch-certutil cert --ca-cert ca/ca.crt --ca-key ca/ca.key --in dns.yaml -pem
```

4. 将证书拷贝到本地并解压

```bash
kubectl cp elasticsearch-0:/usr/share/elasticsearch/elastic-stack-ca.zip elastic-stack-ca.zip -n default
kubectl cp elasticsearch-0:/usr/share/elasticsearch/certificate-bundle.zip certificate-bundle.zip -n default
```

5. 创建secret

```bash
kubectl create secret generic es-transport-certs --from-file=ca.crt=ca.crt --from-file=es.crt=es.crt --from-file=es.key=es.key -n default
```

6. 修改es配置文件

```yaml
          volumeMounts:
            - name: es-transport-certs
              mountPath: /usr/share/elasticsearch/config/certs

    volumes:
        - name: es-transport-certs
          secret:
            secretName: es-transport-certs
```

```yaml
        env:
            - name: xpack.security.enabled
              value: "true"
            - name: xpack.security.transport.ssl.enabled
              value: "true"
            - name: xpack.security.transport.ssl.certificate_authorities
              value: "/usr/share/elasticsearch/config/certs/ca.crt"
            - name: xpack.security.transport.ssl.certificate
              value: "/usr/share/elasticsearch/config/certs/es.crt"
            - name: xpack.security.transport.ssl.key
              value: "/usr/share/elasticsearch/config/certs/es.key"
```

7. 应用并重启pod

```bash
kubectl apply -f es-deployment.yaml
```

8. 设置密码

```bash
curl -u elastic:当前密码 -X POST "https://127.0.0.1:9200/_security/user/elastic/_password" \
-H "Content-Type: application/json" \
-d '{"password":"新密码"}'
```

或者

```bash
kubectl exec -it elasticsearch-0 -n default -- bash
bin/elasticsearch-setup-passwords interactive
```

9. 修改kibana配置文件

