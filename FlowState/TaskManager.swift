import Foundation

class TaskManager: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var completedTasks: [TaskItem] = []
    @Published var moodStats: [String: Int] = [:]
    
    private let tasksKey = "savedTasks"
    private let completedTasksKey = "completedTasks"
    private let moodStatsKey = "moodStats"

    init() {
        loadTasks()
        loadMoodStats()
    }

    private func loadMoodStats() {
        if let data = UserDefaults.standard.dictionary(forKey: moodStatsKey) as? [String: Int] {
            moodStats = data
        }
    }

    private func saveMoodStats() {
        UserDefaults.standard.set(moodStats, forKey: moodStatsKey)
    }

    func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: tasksKey)

            let completedData = try JSONEncoder().encode(completedTasks)
            UserDefaults.standard.set(completedData, forKey: completedTasksKey)
        } catch {
            print("Error saving tasks: \(error)")
        }
    }

    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey) {
            do {
                tasks = try JSONDecoder().decode([TaskItem].self, from: data)
            } catch {
                print("Error loading tasks: \(error)")
            }
        }
        if let completedData = UserDefaults.standard.data(forKey: completedTasksKey) {
            do {
                completedTasks = try JSONDecoder().decode([TaskItem].self, from: completedData)
            } catch {
                print("Error loading completed tasks: \(error)")
            }
        }
    }

    func addTask(_ task: TaskItem) {
        tasks.append(task)
        saveTasks()
    }

    func updateTask(_ task: TaskItem) {
        if task.isCompleted {
            moveTaskToCompleted(task)
        } else {
            // If task was previously completed, move it back to active tasks
            if let index = completedTasks.firstIndex(where: { $0.id == task.id }) {
                completedTasks.remove(at: index)
                tasks.append(task)
                
                // Update mood stats
                if let mood = task.mood {
                    moodStats[mood] = (moodStats[mood] ?? 1) - 1
                    saveMoodStats()
                }
            } else if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = task
            }
            saveTasks()
        }
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        completedTasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func clearCompletedTasks() {
        completedTasks.removeAll()
        saveTasks()
    }

    func resetMoodStats() {
        moodStats.removeAll()
        saveMoodStats()
    }

    private func moveTaskToCompleted(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        completedTasks.append(task)
        
        // Update mood stats independently
        if let mood = task.mood {
            moodStats[mood, default: 0] += 1
            saveMoodStats()
        }
        
        saveTasks()
    }
}
