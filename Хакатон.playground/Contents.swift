import UIKit

// Так как во время реальзации проекта многое было подчерпнуто из вебинара по разбору хакатона, я добавила к заданию еще пару пунктов для самопроверки: смена пин-кода и отображение сразу всех балансов

// Абстракция данных пользователя
protocol UserData {
  var userName: String { get }    //Имя пользователя
  var userCardId: String { get }   //Номер карты
  var userCardPin: Int { get set}       //Пин-код
  var userPhone: String { get }       //Номер телефона
  var userCash: Float { get set }   //Наличные пользователя
  var userBankDeposit: Float { get set }   //Банковский депозит
  var userPhoneBalance: Float { get set }    //Баланс телефона
  var userCardBalance: Float { get set }    //Баланс карты
}

class User: UserData {
    var userName: String
    var userCardId: String
    var userCardPin: Int
    var userPhone: String
    var userCash: Float
    var userBankDeposit: Float
    var userPhoneBalance: Float
    var userCardBalance: Float
    
    init (userName: String, userCardId: String, userCardPin: Int, userPhone: String, userCash: Float, userBankDeposit: Float, userPhoneBalance: Float, userCardBalance: Float) {
        
        self.userName = userName
        self.userCardId = userCardId
        self.userCardPin = userCardPin
        self.userPhone = userPhone
        self.userCash = userCash
        self.userBankDeposit = userBankDeposit
        self.userPhoneBalance = userPhoneBalance
        self.userCardBalance = userCardBalance
    }
}


// Действия, которые пользователь может выбирать в банкомате (имитация кнопок)
enum UserActions {
    case cardBalanceRequest // Запрос баланса карты
    case depositBalanceRequest // Запрос баланса депозита
    case requestAllBalance // Запрос баланса по карте, депозиту и телефону
    case cashReceiving(withdraw: Float) // Снятие наличных
    case cashReplenishment(topUp: Float) // Пополнение наличными
    case phoneReplenishment(phone: String) // Пополнение телефона
    case cardPinChanging(newPin: Int) // Поменять пинкод на карте
}


// Виды операций, выбранных пользователем (подтверждение выбора)
enum DescriptionTypesAvailableOperations: String {
    case confirmCardBalanceRequest = "запрос баланса карты"
    case confirmDepositBalanceRequest = "запрос баланса депозита"
    case confirmCardCashReceiving = "снятие наличных с карты"
    case confirmDepositCashReceiving = "снятие наличных с депозита"
    case confirmCardCashReplenishment = "пополнение баланса карты наличными"
    case confirmDepositCashReplenishment = "пополнение баланса депозита наличными"
    case confirmCashPhoneReplenishment = "пополнение телефона наличными"
    case confirmCardPhoneReplenishment = "пополнение телефона с баланса карты"
    case confirmDepositPhoneReplenishment = "пополнение телефона с баланса депозита"
    case confifmCardPinChanging = "поменять пин-код"
    case confirmRequestAllBalance = "запрос доступных балансов"
}
 
// Способ оплаты/пополнения наличными, картой или через депозит
enum PaymentMethod {
    case cash(cash: Float)
    case card(card: Float)
    case deposit(deposit: Float)
}

// Тексты ошибок
enum TextErrors: String {
    case notEnoughMoneyOnCard = "на Вашей карте не достаточно средств"
    case notEnoughMoneyOnDeposit = "на Вашем счете не достаточно средств"
    case incorrectCardPinOrCardId = "введены неверные данные карты или пин-код"
    case incorrectPhoneNumber = "номер телефона введен не верно"
}
 

// Протокол по работе с банком предоставляет доступ к данным пользователя зарегистрированного в банке
protocol BankApi {
    func showUserCardBalance() // показать баланс карты
    func showUserDepositBalance() // показать баланс депозита
    func showUserToppedUpMobilePhoneCash(cash: Float) // показать пополнение телефона наличными
    func showUserToppedUpMobilePhoneCard(card: Float) // показать пополнение телефона картой
    func showUserToppedUpMobilePhoneDeposit(deposit: Float)
    func showWithdrawalCard(cash: Float) // показать снятие наличных с карты
    func showWithdrawalDeposit(cash: Float) // показать снятие наличных с депозита
    func showTopUpCard(cash: Float) // показать пополнение карты
    func showTopUpDeposit(cash: Float) // показать пополнение депозита
    func showCurrentCardPin()
    func showAllBalance()// показать актуальный пин-код
    func showError(error: TextErrors) // показать ошибку
 
    func checkUserPhone(phone: String) -> Bool // проверка правильности телефона
    func checkMaxUserDeposit(withdraw: Float) -> Bool // проверка достаточных средств на депозите
    func checkMaxUserCard(withdraw: Float) -> Bool // проверка достаточных средств на карте
    func checkCurrentUser(userCardId: String, userCardPin: Int) -> Bool // проверка верных данных пользователя
 
    mutating func topUpPhoneBalanceCash(pay: Float) // пополнение телефона наличными
    mutating func topUpPhoneBalanceCard(pay: Float) // пополнение телефона картой
    mutating func topUpPhoneBalanceDeposit(pay: Float) // пополнение телефона депозитом
    mutating func getCashFromDeposit(cash: Float) // снятие наличных с депозита
    mutating func getCashFromCard(cash: Float) // снятие наличных с карты
    mutating func putCashDeposit(topUp: Float) // внесение наличных на депозит
    mutating func putCashCard(topUp: Float) // внесение наличных на нарту
    mutating func changeCardPin(newPin: Int)// изменение пин-кода
}
 

// Банкомат, с которым мы работаем, имеет общедоступный интерфейс sendUserDataToBank
class ATM {
    private let userCardId: String
    private let userCardPin: Int
    private var someBank: BankApi
    private let action: UserActions
    private let paymentMethod: PaymentMethod?
 
    init(userCardId: String, userCardPin: Int, someBank: BankApi, action: UserActions, paymentMethod: PaymentMethod? = nil) {
        self.userCardId = userCardId
        self.userCardPin = userCardPin
        self.someBank = someBank
        self.action = action
        self.paymentMethod = paymentMethod
 
        sendUserDataToBank(userCardId: userCardId, userCardPin: userCardPin, actions: action, payment: paymentMethod)
    }
    
    
    public final func sendUserDataToBank(userCardId: String, userCardPin: Int, actions: UserActions, payment: PaymentMethod?) {
    let existingUser = someBank.checkCurrentUser(userCardId: userCardId, userCardPin: userCardPin)
    if existingUser {
        switch actions {
        case .cardBalanceRequest:
            someBank.showUserCardBalance()
        case .depositBalanceRequest:
            someBank.showUserDepositBalance()
        case .cashReceiving: // снятие наличных с карты или депозита
            if let payment = payment {
                switch payment { // перебираем способы снятия денег
                case let .card(card: payment):
                    if someBank.checkMaxUserCard(withdraw: payment) { // проверяем, хватает ли денег на карте
                        someBank.getCashFromCard(cash: payment)
                        someBank.showWithdrawalCard(cash: payment)
                    } else {
                        someBank.showError(error: .notEnoughMoneyOnCard)
                    }
                case let .deposit(deposit: payment):
                    if someBank.checkMaxUserDeposit(withdraw: payment) { //проверяем, хватает ли денег на депозите
                        someBank.getCashFromDeposit(cash: payment)
                        someBank.showWithdrawalDeposit(cash: payment)
                    } else {
                        someBank.showError(error: .notEnoughMoneyOnDeposit)
                    }
                case .cash(cash: _):
                    break
                }
            }
        case .cashReplenishment: // пополнение карты или депозита
            if let payment = payment {
                switch payment { // перебираем, куда кладем деньги
                case let .card(card: payment):
                    someBank.putCashCard(topUp: payment)
                    someBank.showTopUpCard(cash: payment)
                case let .deposit(deposit: payment):
                    someBank.putCashDeposit(topUp: payment)
                    someBank.showTopUpDeposit(cash: payment)
                case .cash(cash: _):
                    break
                }
            }
        case let .phoneReplenishment(phone): // пополнение телефона картой или наличными
            if someBank.checkUserPhone(phone: phone) { // проверка правильности телефона
                if let payment = payment {
                    switch payment { // перебираем способы оплаты
                    case let .card(card: payment):
                        if someBank.checkMaxUserCard(withdraw: payment) { // проверяем, хватает ли денег на карте
                            someBank.topUpPhoneBalanceCard(pay: payment)
                            someBank.showUserToppedUpMobilePhoneCard(card: payment)
                        } else {
                            someBank.showError(error: .notEnoughMoneyOnCard)
                        }
                    case let .cash(cash: payment):
                        someBank.topUpPhoneBalanceCash(pay: payment)
                        someBank.showUserToppedUpMobilePhoneCash(cash: payment)
                    case let .deposit(deposit: payment):
                        if someBank.checkMaxUserDeposit(withdraw: payment) { // проверяем, хватает ли денег на депозите
                            someBank.topUpPhoneBalanceDeposit(pay: payment)
                            someBank.showUserToppedUpMobilePhoneDeposit(deposit: payment)
                        } else {
                            someBank.showError(error: .notEnoughMoneyOnDeposit)
                        }
                    }
                }
                } else {
                    someBank.showError(error: .incorrectPhoneNumber)
                }
            
                
        case let .cardPinChanging (newPin): // замена пин-кода
            
            someBank.changeCardPin(newPin: newPin)
                someBank.showCurrentCardPin()
            
        case .requestAllBalance:
            someBank.showAllBalance()
        }
        
        
    } else {
           someBank.showError(error: .incorrectCardPinOrCardId)
        }
    }
}



struct BankServer: BankApi {
    private var user: UserData
    
    init(user: UserData) {
        self.user = user
    }
    
    func showUserCardBalance() {  // показать баланс карты
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmCardBalanceRequest.rawValue)
        Баланс карты: \(user.userCardBalance) \u{20bd}

        """
        print(message)
    }
    
    func showUserDepositBalance() { // показать баланс депозита
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmDepositBalanceRequest.rawValue)
        Баланс карты: \(user.userBankDeposit) \u{20bd}

        """
        print(message)
    }
    
    func showUserToppedUpMobilePhoneCash(cash: Float) { // показать пополнение телефона наличными
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmCashPhoneReplenishment.rawValue)
        Сумма пополнения: \(cash) \u{20bd}
        Баланс телефона: \(user.userPhoneBalance) \u{20bd}

        """
        print(message)
    }
    
    func showUserToppedUpMobilePhoneCard(card: Float) { // показать пополнение телефона картой
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmCardPhoneReplenishment.rawValue)
        Сумма пополнения: \(card) \u{20bd}
        Баланс телефона: \(user.userPhoneBalance) \u{20bd}
        Остаток на балансе карты: \(user.userCardBalance) \u{20bd}

        """
        print(message)
    }
    
    func showUserToppedUpMobilePhoneDeposit(deposit: Float) { // показать пополнение телефона депозитом
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmDepositPhoneReplenishment.rawValue)
        Сумма пополнения: \(deposit) \u{20bd}
        Баланс телефона: \(user.userPhoneBalance) \u{20bd}
        Остаток на балансе депозита: \(user.userBankDeposit) \u{20bd}

        """
        print(message)
    }
    
    func showWithdrawalCard(cash: Float) { // показать снятие наличных с карты
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmCardCashReceiving.rawValue)
        Сумма снятия: \(cash) \u{20bd}
        Остаток на балансе карты: \(user.userCardBalance) \u{20bd}

        """
        print(message)
    }
    
    func showWithdrawalDeposit(cash: Float) { // показать снятие наличных с депозита
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmDepositCashReceiving.rawValue)
        Сумма снятия: \(cash) \u{20bd}
        Остаток на балансе депозита: \(user.userBankDeposit) \u{20bd}

        """
        print(message)
    }
    
    func showTopUpCard(cash: Float) { // показать пополнение карты наличными
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmCardCashReplenishment.rawValue)
        Сумма пополнения: \(cash) \u{20bd}
        Остаток на балансе карты: \(user.userCardBalance) \u{20bd}

        """
        print(message)
    }
    
    func showTopUpDeposit(cash: Float) { // показать пополнение депозита наличными
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmDepositCashReplenishment.rawValue)
        Сумма пополнения: \(cash) \u{20bd}
        Остаток на балансе карты: \(user.userBankDeposit) \u{20bd}

        """
        print(message)
    }
    
    func showCurrentCardPin() {
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confifmCardPinChanging.rawValue)
        Новый пин-код: \(user.userCardPin)

        """
        print(message)
    }
    
    func showAllBalance() {
        let message = """
        Здравствуйте, \(user.userName)!
        Вы выбрали операцию: \(DescriptionTypesAvailableOperations.confirmRequestAllBalance.rawValue)
        Баланс Вашей карты: \(user.userCardBalance) \u{20bd}
        Баланс Вашего счета: \(user.userBankDeposit) \u{20bd}
        Баланс Вашего телефона: \(user.userPhoneBalance) \u{20bd}

        """
        print(message)
    }
    
    func showError(error: TextErrors) { // показать ошибку
        let message = """
        Здравствуйте!
        К сожалению, \(error.rawValue)

        """
        print(message)
    }
    
    func checkUserPhone(phone: String) -> Bool { // проверить правильность телефона
        if phone == user.userPhone {
            return true
        }
        return false
    }
    
    func checkMaxUserDeposit(withdraw: Float) -> Bool { // проверить, достаточно ли денег на депозите
        if withdraw <= user.userBankDeposit {
            return true
        }
        return false
    }
    
    func checkMaxUserCard(withdraw: Float) -> Bool { // проверить, достаточно ли денег на карте
        if withdraw <= user.userCardBalance {
            return true
        }
        return false
    }
    
    func checkId(id: String, user: UserData) -> Bool {
        if id == user.userCardId {
            return true
        }
        return false
    }
    func checkPin(pin: Int, user: UserData) -> Bool {
        if pin == user.userCardPin {
            return true
        }
        return false
    }
    
    func checkCurrentUser(userCardId: String, userCardPin: Int) -> Bool { // проверить правильность введенных данных
        let correctId = checkId(id: userCardId, user: user)
        let correctPin = checkPin(pin: userCardPin, user: user)
        if correctId && correctPin {
            return true
        }
        return false
    }
    
    mutating func topUpPhoneBalanceCash(pay: Float) { //функция, увеличивающая баланс телефона наличными
        user.userPhoneBalance += pay
        user.userCash -= pay
    }
    
    mutating func topUpPhoneBalanceCard(pay: Float) { //функция, увеличивающая баланс телефона картой
        user.userPhoneBalance += pay
        user.userCardBalance -= pay
    }
    
    mutating func topUpPhoneBalanceDeposit(pay: Float) { //функция, увеличивающая баланс телефона депозитом
        user.userPhoneBalance += pay
        user.userBankDeposit -= pay
    }
    
    mutating func getCashFromDeposit(cash: Float) { // функция, уменьшающая баланс депозита
        user.userBankDeposit -= cash
        user.userCash += cash
    }
    
    mutating func getCashFromCard(cash: Float) { // функция, уменьшающая баланс карты
        user.userCardBalance -= cash
        user.userCash += cash
    }
    
    mutating func putCashDeposit(topUp: Float) {  // ф-ция, увеличивающая баланс депозита
        user.userBankDeposit += topUp
        user.userCash -= topUp
    }
    
    mutating func putCashCard(topUp: Float) {  // ф-ция, увеличивающая баланс карты
        user.userCardBalance += topUp
        user.userCash -= topUp
    }
    
    mutating func changeCardPin(newPin: Int) {
        user.userCardPin = newPin
    }
    
    
}


// Создадим пользователя
let user1 = User(userName: "Иван Иванов", userCardId: "1111 2222 3333 4444", userCardPin: 1234, userPhone: "8 961 234 5678", userCash: 4567.89, userBankDeposit: 34570.47, userPhoneBalance: -24.45, userCardBalance: 8524.64)

let bankClient = BankServer(user: user1)


// представим действия пользователя через отдельный банкомат (без ошибок)
let action1 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .cardBalanceRequest)

let action2 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .depositBalanceRequest)

let action3 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .cashReceiving(withdraw: 345), paymentMethod: .card(card: 345))

let action4 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .cashReceiving(withdraw: 876), paymentMethod: .deposit(deposit: 876))

let action5 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .cashReplenishment(topUp: 2500), paymentMethod: .card(card: 2500))

let action6 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .cashReplenishment(topUp: 100), paymentMethod: .deposit(deposit: 100))

let action7 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .phoneReplenishment(phone: "8 961 234 5678"), paymentMethod: .cash(cash: 150))

let action8 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .phoneReplenishment(phone: "8 961 234 5678"), paymentMethod: .card(card: 200))

let action9 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .phoneReplenishment(phone: "8 961 234 5678"), paymentMethod: .deposit(deposit: 450))

let action10 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .cardPinChanging(newPin: 1256))

let action11 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1256, someBank: bankClient, action: .requestAllBalance)

// представим действия пользователя через отдельный банкомат (с ошибками)
let action12 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1234, someBank: bankClient, action: .cardBalanceRequest)

let action13 = ATM(userCardId: "1111 2222 3333 0000", userCardPin: 1256, someBank: bankClient, action: .cardBalanceRequest)

let action14 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1256, someBank: bankClient, action: .cashReceiving(withdraw: 50000), paymentMethod: .card(card: 50000))

let action15 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1256, someBank: bankClient, action: .cashReceiving(withdraw: 50000), paymentMethod: .deposit(deposit: 50000))

let action16 = ATM(userCardId: "1111 2222 3333 4444", userCardPin: 1256, someBank: bankClient, action: .phoneReplenishment(phone: "8 961 000 0000"), paymentMethod: .card(card: 100))

