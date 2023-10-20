protoc:
	protoc Sources/ImageEmbossGRPC/embosser.proto \
		--proto_path=Sources/ImageEmbossGRPC/ \
		--plugin=/opt/homebrew/bin/protoc-gen-swift \
		--swift_opt=Visibility=Public \
		--swift_out=Sources/ImageEmbossGRPC/ \
		--plugin=/opt/homebrew/bin/protoc-gen-grpc-swift \
		--grpc-swift_opt=Visibility=Public \
		--grpc-swift_out=Sources/ImageEmbossGRPC/

server:
	./.build/debug/image-emboss-grpc-server \
		--log_file ./logs/image-emboss-grpc-server.log
