import ArgumentParser

@main
struct RouteGuide: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "image-embosser",
    subcommands: [Serve.self, Client.self],
    defaultSubcommand: Serve.self,
  )
}
