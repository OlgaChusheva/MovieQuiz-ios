import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswear: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresent: AlertPresenter?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(),delegate: self)
        alertPresent = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
        presenter.viewController = self
    }
    
    // MARK: - QuestionFactoryDelegate
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        //       hideLoadingIndicator()
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else {return}
                self.presenter.resetQuestionIndex()
                self.correctAnswear = 0
                self.questionFactory?.requestNextQuestion()
            }
          alertPresent?.show(alertModel: model)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) //  качестве сообщения описание ошибки

    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        self.currentQuestion = question
        let viewModel = presenter.convert(model: question ?? question!)
           self.show(quize: viewModel)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
 
    private func show(quize step: QuizStepViewModel){
        imageView.layer.borderColor=UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.text
        counterLabel.text = step.questionNumber
    }

private func show(quiz result: QuizResultsViewModel) {
      //  statisticService?.store(correct: 1, total: 1)
    statisticService?.store(correct: correctAnswear, total: presenter.questionsAmount)
    let currentGamesResulLine = "Ваш результат: \(correctAnswear)\\\(presenter.questionsAmount)"
    let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
        guard let self = self else { return }
        
        self.presenter.resetQuestionIndex()
    }
     let alertModel = AlertModel(
            title: "",
            message: "",
            buttonText: "",
            completion: { [weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswear = 0
                self?.questionFactory?.requestNextQuestion()
           }
        )
    
    alertPresent?.show(alertModel: alertModel)    
    }
    
     func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        if isCorrect {
            correctAnswear += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        if presenter.isLastQuestion() {
            showFinalResult()
        } else {
            presenter.switchToNextQuestion() // увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий
            // показать следующий вопрос
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResult() {
        statisticService?.store(correct: correctAnswear, total: presenter.questionsAmount)
        
    let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswear = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
        alertPresent?.show(alertModel: alertModel)
    }

    private func makeResultMessage() -> String {
        
        guard let statisticService = statisticService else {
            return "Пока рекордов нет"
        }
        
        let accuracy = String(format: "%.2f" , statisticService.totalAccuracy)
        let totalPlaysCountLine = """
        Количество сыгранных квизов: \(statisticService.gamesCount)
        """
        let currentGameResult = """
        Ваш результат: \(correctAnswear)\\\(presenter.questionsAmount)
        """
        var bestGameInfoLine = ""
        if let gameRecord = statisticService.gameRecord {
            bestGameInfoLine = "Рекорд: \(gameRecord.correct)\\\(gameRecord.total)"
            + "(\(gameRecord.date.dateTimeString))"
        }
        let averageAccuaryLine = "Cредняя точность: \(accuracy)%"
        
        let resultMessage = [
            currentGameResult, totalPlaysCountLine, bestGameInfoLine, averageAccuaryLine].joined(separator: "\n")
        
       return resultMessage
    }
        
        @IBAction private func yesButtonClicked(_ sender: UIButton) {
            presenter.currentQuestion = currentQuestion
            presenter.yesButtonClicked()
        }
        
        @IBAction private func noButtonClicked(_ sender: UIButton) {
            presenter.currentQuestion = currentQuestion
            presenter.noButtonClicked()
        }
    }
