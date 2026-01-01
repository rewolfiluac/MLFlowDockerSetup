# SPEC.md - プロジェクト仕様書

## プロジェクト概要

**MLFlowDockerSetup** は、機械学習の実験管理ツール MLflow を Docker Compose で簡単に構築するためのセットアップです。

## システム構成

```
┌─────────────────────────────────────────────────────────┐
│                    nginx_network                        │
│                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │   mlflow    │───▶│    mysql    │    │    minio    │ │
│  │  :5000      │    │   (5.7)     │    │   :9000     │ │
│  │  Tracking   │───▶│  Backend    │    │  Artifact   │ │
│  │  Server     │    │  Store      │    │  Storage    │ │
│  └─────────────┘    └─────────────┘    └─────────────┘ │
│         │                                     ▲        │
│         └─────────────────────────────────────┘        │
│                                                         │
│  ┌───────────────┐                                     │
│  │ defaultbucket │ (起動時にバケット作成後終了)         │
│  └───────────────┘                                     │
└─────────────────────────────────────────────────────────┘
```

## コンテナ一覧

| コンテナ | イメージ | 役割 | ポート |
|---------|---------|------|--------|
| mlflow | カスタム (Ubuntu 22.04) | MLflow Tracking Server | 5000 |
| mysql | mysql:5.7 | 実験メタデータ保存 | - (内部) |
| minio | minio/minio | アーティファクト保存 (S3互換) | 9000 |
| defaultbucket | minio/mc | 初期バケット `default` 作成 | - |

## 技術スタック

- **コンテナ**: Docker / Docker Compose v3
- **MLflow**: Python 3.10 + mlflow, mysqlclient, sqlalchemy, boto3
- **データベース**: MySQL 5.7
- **ストレージ**: MinIO (S3互換オブジェクトストレージ)

## 起動方法

```bash
docker compose up -d --build
```

## 公開ポート

| ポート | サービス | 用途 |
|--------|---------|------|
| 5000 | MLflow | Tracking UI / API |
| 9000 | MinIO | S3 API |
| 9001 | MinIO | Web Console (管理UI) |

## MLflow サーバー設定

MLflow Tracking Server は `--serve-artifacts` オプションを使用し、アーティファクトへのアクセスをサーバー経由で行います。これにより、クライアントは MinIO に直接接続する必要がなく、`http://localhost:5000` への接続のみで完結します。

```
クライアント → MLflow Server (5000) → MinIO (9000)
```

## 環境変数

### MLflow コンテナ

| 変数 | 値 |
|------|-----|
| MLFLOW_S3_ENDPOINT_URL | http://minio:9000 |
| AWS_ACCESS_KEY_ID | minio-access-key |
| AWS_SECRET_ACCESS_KEY | minio-secret-key |

### MySQL コンテナ

| 変数 | 値 |
|------|-----|
| MYSQL_ROOT_PASSWORD | root-password |
| MYSQL_DATABASE | mlflowdb |
| MYSQL_USER | mlflowuser |
| MYSQL_PASSWORD | mlflowpassword |

### MinIO コンテナ

| 変数 | 値 |
|------|-----|
| MINIO_ROOT_USER | minio-access-key |
| MINIO_ROOT_PASSWORD | minio-secret-key |

## ボリューム

| ボリューム | マウント先 | 用途 |
|-----------|-----------|------|
| mysql | /var/lib/mysql | MySQL データ |
| minio1 | /export | MinIO オブジェクト |

## ライセンス

MIT License (c) 2023 rewolfiluac
