protoc:
	protoc Sources/ImageEmbossGRPC/embosser.proto \
		--proto_path=Sources/ImageEmbossGRPC/ \
		--plugin=/opt/homebrew/bin/protoc-gen-swift \
		--swift_opt=Visibility=Public \
		--swift_out=Sources/ImageEmbossGRPC/ \
		--plugin=/opt/homebrew/bin/protoc-gen-grpc-swift \
		--grpc-swift_opt=Visibility=Public \
		--grpc-swift_out=Sources/ImageEmbossGRPC/

debug:
	./.build/debug/image-emboss-grpc-server

debug-tls:
	./.build/debug/image-emboss-grpc-server \
		--tls_certificate ./tls/server.crt \
		--tls_key ./tls/server.key

tls:
	openssl genrsa -out tls/server.key 4096
	openssl req -new -key tls/server.key -out tls/server.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=server"
	openssl x509 -key tls/server.key -in tls/server.csr -out tls/server.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=server" -req
