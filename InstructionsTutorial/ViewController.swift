import UIKit
import Instructions

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!

    @IBOutlet weak var tbVwController: UITableView!
    let coachMarksController = CoachMarksController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        tbVwController.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tbVwController.delegate = self
        tbVwController.dataSource = self
        tbVwController.reloadData()
        DispatchQueue.main.async {
            self.showCoachMarkForCell(row: 2)
        }


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !AppManager.getUserSeenAppInstruction() {
            self.coachMarksController.start(in: .viewController(self))
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.coachMarksController.stop(immediately: true)
    }
}

extension ViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {

    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 6
    }
   
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0: return coachMarksController.helper.makeCoachMark(for: segmentedControl)
        case 1: return coachMarksController.helper.makeCoachMark(for: searchTextField)
        case 2: return coachMarksController.helper.makeCoachMark(for: textLabel)
        case 3: return coachMarksController.helper.makeCoachMark(for: controlButton)
        case 4:
            let indexPath = IndexPath(row: 2, section: 0)
            
            tbVwController.scrollToRow(at: indexPath, at: .middle, animated: false)

            if let cell = tbVwController.cellForRow(at: indexPath) as? TableViewCell {
                print("Successfully accessed button for row 2")
                return coachMarksController.helper.makeCoachMark(for: cell.button)
            } else {
                print("Failed to access cell for row 2")
                return coachMarksController.helper.makeCoachMark()
            }
        case 5 : var indexPath = IndexPath(row: 8, section: 0)
             indexPath = IndexPath(row: 7, section: 0)
               // Scroll to row 8 to ensure visibility
               tbVwController.scrollToRow(at: indexPath, at: .middle, animated: true)
            self.tbVwController.layoutIfNeeded()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let cell = self.tbVwController.cellForRow(at: indexPath) as? TableViewCell {
                    print("Successfully laid out and accessed button for row 8")
                    self.coachMarksController.helper.makeCoachMark(for: cell.button)
                   
                  
                } else {
                    print("Cell for row 8 is still nil after scrolling")
                }
            }
            return coachMarksController.helper.makeCoachMark()
                    // Return a placeholder coach mark (won't be shown as `showNext` will trigger next)
        default: return coachMarksController.helper.makeCoachMark()
        }
        
    }
    func showCoachMarkForCell(row:Int) {
        let indexPath = IndexPath(row: row, section: 0) // Adjust to your target row
        tbVwController.scrollToRow(at: indexPath, at: .middle, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Delay to ensure scrolling is completed
            self.coachMarksController.start(in: .viewController(self))
        }
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)

        // 1. Create the "Tips" heading with left-side image
        let headingImageView = UIImageView(image: UIImage(named: "Vector")) // Add your image here
        headingImageView.contentMode = .scaleAspectFit
        headingImageView.translatesAutoresizingMaskIntoConstraints = false

        let tipsHeadingLabel = UILabel()
        tipsHeadingLabel.text = "Tips Heading"
        tipsHeadingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        tipsHeadingLabel.textColor = .black
        tipsHeadingLabel.translatesAutoresizingMaskIntoConstraints = false

        // Horizontal stack view to hold the image and label
        let headingStackView = UIStackView(arrangedSubviews: [headingImageView, tipsHeadingLabel])
        headingStackView.axis = .horizontal
        headingStackView.spacing = 8
        headingStackView.alignment = .center
        headingStackView.translatesAutoresizingMaskIntoConstraints = false

        // Add headingStackView to the body view
        coachViews.bodyView.addSubview(headingStackView)

        // Constraints for the heading stack view
        NSLayoutConstraint.activate([
            headingStackView.topAnchor.constraint(equalTo: coachViews.bodyView.topAnchor, constant: 10),
            headingStackView.leadingAnchor.constraint(equalTo: coachViews.bodyView.leadingAnchor, constant: 20),
            headingStackView.heightAnchor.constraint(equalToConstant: 20) // Adjust the height as needed
        ])

        // 2. Create a stack view for the hint and next labels
        let stackView = UIStackView(arrangedSubviews: [coachViews.bodyView.hintLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill

        coachViews.bodyView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: headingStackView.bottomAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: coachViews.bodyView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: coachViews.bodyView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: coachViews.bodyView.bottomAnchor, constant: -40) // Space for buttons
        ])

        // 3. Add "Skip" button at the bottom-right corner
        let skipButton = UIButton(type: .system)
        skipButton.setTitle("Skip guide", for: .normal)
        skipButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        skipButton.tintColor = .systemGray

        skipButton.addTarget(self, action: #selector(skipAction), for: .touchUpInside)
        coachViews.bodyView.addSubview(skipButton)
        
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skipButton.bottomAnchor.constraint(equalTo: coachViews.bodyView.bottomAnchor, constant: -13),
            skipButton.trailingAnchor.constraint(equalTo: coachViews.bodyView.trailingAnchor, constant: -20)
        ])

        // 4. Add "OK" label at the bottom-left corner
        let okLabel = UILabel()
        okLabel.text = "Next  >"
        okLabel.font = .boldSystemFont(ofSize: 16)
        okLabel.textColor = .black
        coachViews.bodyView.addSubview(okLabel)

        okLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            okLabel.bottomAnchor.constraint(equalTo: coachViews.bodyView.bottomAnchor, constant: -20),
            okLabel.leadingAnchor.constraint(equalTo: coachViews.bodyView.leadingAnchor, constant: 22)
        ])

        // 5. Customize hint and next labels based on index
        switch index {
        case 0:
            coachViews.bodyView.hintLabel.text = "Hello! This is a segmented control you can toggle dark and light mode here!, Hello! This is a segmented control you can toggle dark and light mode here!,Hello! This is a segmented control you can toggle dark and light mode here!"
        case 1:
            coachViews.bodyView.hintLabel.text = "This is a search text field you can search for your favourite texts here.,Hello! This is a segmented control you can toggle dark and light mode here!"
        case 2:
            coachViews.bodyView.hintLabel.text = "Your search text will appear here when you hit enter.,Hello! This is a segmented control you can toggle dark and light mode here!"
        case 3:
            coachViews.bodyView.hintLabel.text = "Finally, you can hit the control button to view your search details!,Hello! This is a segmented control you can toggle dark and light mode here!"
        case 4:
            coachViews.bodyView.hintLabel.text = "Case 4 Finally, you can hit the control button to view your search details!,Hello! This is a segmented control you can toggle dark and light mode here!"
        case 5:
            coachViews.bodyView.hintLabel.text = "Case 4 Finally, you can hit the control button to view your search details!,Hello! This is a segmented control you can toggle dark and light mode here!"
        default: break
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }

    // Action for "Skip" button
    @objc func skipAction() {
        // Implement skip functionality (dismiss the coach mark)
        print("Coach Mark Skipped!")
        self.coachMarksController.stop(immediately: true)
    }




   


    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        AppManager.setUserSeenAppInstruction()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : TableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        if let button = cell.button {
                button.tag = indexPath.row
            } else {
                print("Button is nil in cell at row \(indexPath.row)")
            }
        return cell
    }
    
    
}
