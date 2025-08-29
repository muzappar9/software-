import Foundation

@objc public class LlamaRunner: NSObject {
  @objc public static func initModel(_ modelPath: String, _ nCtx: Int, _ nThreads: Int) -> Bool {
    // 占位实现
    return true
  }

  @objc public static func generate(_ prompt: String, _ maxTokens: Int) -> String {
    return "[占位回复] 已收到提示：\(prompt.prefix(80))"
  }

  @objc public static func unload() {
    // 占位
  }
}

