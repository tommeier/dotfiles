alias delete_unavailable_simulators='xcrun simctl delete unavailable'

function close_simulators {
  echo "Ensure all possible clients of CoreSimulatorService are no longer running:"
  killall Xcode 2> /dev/null
  killall Instruments 2> /dev/null
  killall 'iOS Simulator' 2> /dev/null
  killall Simulator 2> /dev/null
  killall 'Simulator (Watch)' 2> /dev/null
  killall ibtoold 2> /dev/null
  killall simctl 2> /dev/null

  echo "Killing simulator:"
  sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService
}

function reset_simulators_state {
  echo "Resetting state of simulators"
  close_simulators

  echo "Removing all the data and logs:"
  rm -rf ~/Library/*/CoreSimulator
}

function delete_appium_simulators {
  xcrun simctl list devices | grep appiumTest | cut -d "(" -f 2 | cut -d ")" -f 1 | xargs xcrun simctl delete
}

function clear_xcode_data {
  echo "Clearing all xcode data"
  close_simulators

  echo "Removing all debug build cache data:"
  rm -rf ~/Library/Developer/Xcode/DerivedData/*

  echo "Removing all build archives:"
  rm -rf ~/Library/Developer/Xcode/Archives/*

  echo "Removing all the simulator data and logs:"
  rm -rf ~/Library/*/CoreSimulator

  echo "Removing XCode 6 old locations:"
  rm -rf ~/Library/Caches/com.apple.dt.Xcode

  echo "Removing old mobile archives:"
  rm -rf "~/Library/Application\ Support/MobileSync/Backup/*"

  echo "Removing device logs:"
  rm -rf "~/Library/Developer/Xcode/iOS\ Device\ Logs/*"

  echo "Done"

  echo
  echo "Manually clear any irrelevent iOS support here: "
  IOS_LOCATION=~/Library/Developer/Xcode/iOS\ DeviceSupport/
  echo "$IOS_LOCATION"

  ls -lh "$IOS_LOCATION"
}
