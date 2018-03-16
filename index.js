import CtrlpanelCore from '@ctrlpanel/core'

let core = new CtrlpanelCore()
let state = null

function swiftState (state) {
  let result = {}

  if (state.kind != null) result.kind = state.kind

  // Locked
  if (state.handle != null) result.handle = state.handle
  if (state.saveDevice != null) result.saveDevice = state.saveDevice
  if (state.secretKey != null) result.secretKey = state.secretKey

  // Unlocked
  if (state.decryptedEntries != null) {
    const parsedEntries = core.getParsedEntries(state)

    // Swift handles UUID keys very poorly :(
    result.parsedEntries = {
      accounts: Object.keys(parsedEntries.accounts).reduce((mem, key) => [...mem, key, parsedEntries.accounts[key]], []),
      inbox: Object.keys(parsedEntries.inbox).reduce((mem, key) => [...mem, key, parsedEntries.inbox[key]], [])
    }
  }

  // Connected
  if (state.hasPaymentInformation != null) result.hasPaymentInformation = state.hasPaymentInformation
  if (state.subscriptionStatus != null) result.subscriptionStatus = state.subscriptionStatus
  if (state.trialDaysLeft != null) result.trialDaysLeft = state.trialDaysLeft

  return result
}

window['Ctrlpanel'] = {
  randomAccountPassword () {
    return CtrlpanelCore.randomAccountPassword()
  },
  randomHandle () {
    return CtrlpanelCore.randomHandle()
  },
  randomMasterPassword () {
    return CtrlpanelCore.randomMasterPassword()
  },
  randomSecretKey () {
    return CtrlpanelCore.randomSecretKey()
  },

  boot (apiHost) {
    core = new CtrlpanelCore(apiHost)
  },
  init (syncToken) {
    return swiftState(state = core.init(syncToken))
  },
  lock () {
    return swiftState(state = core.lock(state))
  },

  async signup (handle, secretKey, masterPassword, saveDevice) {
    return swiftState(state = await core.signup(state, handle, secretKey, masterPassword, saveDevice))
  },
  async login (handle, secretKey, masterPassword, saveDevice) {
    return swiftState(state = await core.login(state, handle, secretKey, masterPassword, saveDevice))
  },
  async unlock (masterPassword) {
    return swiftState(state = await core.unlock(state, masterPassword))
  },
  async connect () {
    return swiftState(state = await core.connect(state))
  },
  async sync () {
    if (state.kind === 'unlocked') await window['Ctrlpanel'].connect()
    if (state.kind !== 'connected') throw new Error(`Invalid state: ${state.kind}`)

    return swiftState(state = await core.sync(state))
  },

  async createAccount (id, account) {
    if (state.kind === 'unlocked') await window['Ctrlpanel'].connect()
    if (state.kind !== 'connected') throw new Error('Vault is locked')

    return swiftState(state = await core.createAccount(state, id.toLowerCase(), account))
  },
  async deleteAccount (id) {
    if (state.kind === 'unlocked') await window['Ctrlpanel'].connect()
    if (state.kind !== 'connected') throw new Error('Vault is locked')

    return swiftState(state = await core.deleteAccount(state, id.toLowerCase()))
  },
  async updateAccount (id, account) {
    if (state.kind === 'unlocked') await window['Ctrlpanel'].connect()
    if (state.kind !== 'connected') throw new Error('Vault is locked')

    return swiftState(state = await core.updateAccount(state, id.toLowerCase(), account))
  },

  async clearStoredData () {
    return swiftState(state = await core.clearStoredData(state))
  }
}
