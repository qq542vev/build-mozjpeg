<!-- Document: README.md

「Build MozJPEG」の日本語マニュアル。

Metadata:

	id - 4d1ec30c-138b-46df-816a-d3051c2f0b2b
	author - <qq542vev at https://purl.org/meta/me/>
	version - 0.1.0
	created - 2026-01-06
	modified - 2026-01-06
	copyright - Copyright (C) 2026-2026 qq542vev. Some rights reserved.
	license - <GPL-3.0-only at https://www.gnu.org/licenses/gpl-3.0.txt>
	conforms-to - <https://spec.commonmark.org/current/>

See Also:

	* <Project homepage at https://github.com/qq542vev/build-mozjpeg>
	* <Bug report at https://github.com/qq542vev/build-mozjpeg/issues>
-->

# Build MozJPEG

このプロジェクトは、複数アーキテクチャのLinux向けにビルドした[MozJPEG]()のプリビルトパッケージ（tar / deb）および Docker / OCI イメージを配布します。ダウンロード・Pull は下記の配布先をご利用ください。

 * [Releases（パッケージ・アーティファクト）](https://gitlab.com/qq542vev/build-mozjpeg/-/releases)
- [Container Registry（Docker / OCI イメージ）](https://gitlab.com/qq542vev/build-mozjpeg/container_registry/9609771)

## サポートされているビルドバリアント

| バリアント   | パッケージ | Docker |
|--------------|------------|--------|
| 386          | ✓          | ×      |
| 386(SIMD)    | ✓          | ×      |
| amd64        | ✓          | ✓      |
| amd64(SMID)  | ✓          | ×      |
| arm/v7       | ✓          | ✓      |
| arm/v7(SIMD) | ✓          | ×      |
| arm64        | ✓          | ✓      |
| arm64(SIMD)  | ✓          | ×      |
| ppc64le      | ✓          | ✓      |
| s390x        | ✓          | ✓      |

## 利用方法

### バイナリ（Releases）

```sh
sudo tar -C / -xjvf mozjpeg-4.1.5-Linux-x86_64.tar.bz2
export PATH="/opt/mozjpeg/bin${PATH:+:}${PATH-}"
export LD_LIBRARY_PATH="/opt/mozjpeg/lib64${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH-}"
jpegtran -version
```

### Docker

```sh
docker pull registry.gitlab.com/qq542vev/build-mozjpeg:v4.1.5
docker run --rm -v "$(pwd):/work" registry.gitlab.com/qq542vev/build-mozjpeg:v4.1.5 jpegtran -copy none -optimize -progressive -outfile output.jpg input.jpg
```

## ライセンス

Build MozJPEGに於いて作成したファイルは<LICENSE.txt>に従います。MozJPEG自体のライセンスは[libjpeg-turbo Licenses](https://gitlab.com/qq542vev/build-mozjpeg/-/blob/master/LICENSE.md)に従います。バージョン毎のライセンス詳細は各リリースに含まれるLICENSEファイルを参照してください。
