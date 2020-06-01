//
//  AVAudioSession.swift
//  Beethoven-macOS
//
//  Created by Rene Hexel on 31/5/20.
//  Copyright © 2020 Rene Hexel. All rights reserved.
//
import Foundation
import AVFoundation

#if os(macOS)
/// MacOS compatibility class, implementing `AVAudioSession`
/// in terms of `AVCaptureSession`
class AVAudioSession: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
  static var shared = AVAudioSession()
  let captureSession = AVCaptureSession()
  var recordPermission: RecordPermission = .denied
  var currentRoute = AVAudioSessionRouteDescription()

  static func sharedInstance() -> AVAudioSession { AVAudioSession.shared }

  func requestRecordPermission(_ response: (Bool) -> Void) {
    if recordPermission != .granted { setup() }
    response(recordPermission == .granted)
  }

  func setCategory(_ category: Category) throws {
    self.category = category
  }

  func overrideOutputAudioPort(_ portOverride: AVAudioSession.PortOverride) throws {
  }

  private var audioDevice: AVCaptureDevice?
  private var audioInput: AVCaptureDeviceInput?
  private var audioDataOutput: AVCaptureAudioDataOutput?
  private var category = Category.playback

  private override init() {
    super.init()
    setup()
  }

  private func setup() {
    switch category {
    case .record, .playAndRecord:
      setupRecording()
    default:
      return
    }
  }

  private func setupRecording() {
    guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
      print("Cannot get default audio device")
      return
    }
    self.audioDevice = audioDevice
    do {
      let audioInput = try AVCaptureDeviceInput(device: audioDevice)
      recordPermission = .undetermined
      guard captureSession.canAddInput(audioInput) else {
        print("Cannot attach audio input")
        return
      }
      captureSession.addInput(audioInput)
      self.audioInput = audioInput
      let audioOutput = AVCaptureAudioDataOutput()
      guard captureSession.canAddOutput(audioOutput) else {
        print("Cannot attach audio output")
        return
      }
      captureSession.addOutput(audioOutput)
      audioDataOutput = audioOutput
      recordPermission = .granted
    } catch {
      print("Cannot create audio device input")
    }
  }

  enum RecordPermission {
    case undetermined
    case denied
    case granted
  }

  enum Category {
    case playback
    case record
    case playAndRecord
  }

  enum Port: String, RawRepresentable {
    case lineIn
    case builtInMic
    case headsetMic
    case lineOut
    case headphones
    case bluetoothA2DP
    case builtInReceiver
    case builtInSpeaker
    case HDMI
    case airPlay
    case bluetoothLE
    case bluetoothHFP
    case usbAudio
    case carAudio
  }

  enum PortOverride: UInt {
    case none = 0
    case speaker = 1936747378
  }

  struct Location {}
  struct Orientation {}
  struct PolarPattern {}
}

class AVAudioSessionRouteDescription {
  var inputs = [AVAudioSessionPortDescription]()
  var outputs = [AVAudioSessionPortDescription]()
}

class AVAudioSessionPortDescription {
  var portType: AVAudioSession.Port = .lineOut
  var portName: String { portType.rawValue }
  var uid: String { portType.rawValue }
  var hasHardwareVoiceCallProcessing = false
  var channels: [AVAudioSessionChannelDescription]? = nil
  var dataSources: [AVAudioSessionDataSourceDescription]? = nil
  var selectedDataSource: AVAudioSessionDataSourceDescription? = nil
  var preferredDataSource: AVAudioSessionDataSourceDescription? = nil
  open func setPreferredDataSource(_ dataSource: AVAudioSessionDataSourceDescription?) throws {
    preferredDataSource = dataSource
  }
}

typealias AudioChannelLabel = UInt32

class AVAudioSessionChannelDescription : NSObject {
  var channelName: String = ""
  var owningPortUID: String = AVAudioSession.Port.lineOut.rawValue
  var channelNumber: Int = 0
  var channelLabel: AudioChannelLabel = 0
}


class AVAudioSessionDataSourceDescription {
  var dataSourceID: NSNumber = 0
  var dataSourceName: String = AVAudioSession.Port.builtInMic.rawValue
  var location: AVAudioSession.Location?
  var orientation: AVAudioSession.Orientation?
  var supportedPolarPatterns: [AVAudioSession.PolarPattern]?
  var selectedPolarPattern: AVAudioSession.PolarPattern?
  var preferredPolarPattern: AVAudioSession.PolarPattern?
  func setPreferredPolarPattern(_ pattern: AVAudioSession.PolarPattern?) throws {
    preferredPolarPattern = pattern
  }
}
#endif
