//
//  GPTService.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import Foundation

class GPTService {
    static let shared = GPTService()
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    // MARK: - Generate Round
    func generateRound(difficulty: Int, jarCount: Int, theme: String = "auto", apiKey: String, completion: @escaping (Result<RoundConfig, Error>) -> Void) {
        let systemPrompt = "You are Mimi, a meticulous candy shop mentor and rigorous puzzle curator. You must output safe, deterministic JSON only."
        
        let userPrompt = """
        Create a Sweet Sorter round for iPhone. Constraints:
        - language: English only
        - jars: \(jarCount)
        - target_complexity: \(difficulty)
        - include_readable_labels: true
        - produce concise_summary: true
        - produce rules in the Rule DSL described below
        - keep rules self-consistent; no overlapping or ambiguous assignments
        - ensure every candy can be classified by exactly one jar or the 'else' jar
        - avoid culturally sensitive terms
        Rule DSL:
        - attributes: color, shape, size, pattern, flavor, wrapped, layers
        - ops: AND, OR, NOT, parentheses
        - comparisons: =, !=, ≥, ≤, >, <
        Output JSON schema:
        {
          "theme": "string",
          "concise_summary": "string (1 sentence)",
          "jars": [
            {"id":"A","label":"string readable name","rule":"Rule DSL string"},
            {"id":"B","label":"string readable name","rule":"Rule DSL string"},
            {"id":"C","label":"string readable name","rule":"Rule DSL string or ELSE"}
          ],
          "twist": {
            "when_seconds": number (or null),
            "description": "string",
            "patch": [{"id":"A|B|C","rule":"new Rule DSL string or ELSE"}]
          }
        }
        Ensure one jar uses ELSE to catch all unclassified items. Keep labels cozy and short.
        """
        
        makeRequest(systemPrompt: systemPrompt, userPrompt: userPrompt, apiKey: apiKey) { result in
            switch result {
            case .success(let jsonString):
                do {
                    let data = jsonString.data(using: .utf8) ?? Data()
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let config = try decoder.decode(RoundConfig.self, from: data)
                    completion(.success(config))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Explain Ruling
    func explainRuling(candy: Candy, jar: Jar, jars: [Jar], apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        let systemPrompt = "You are Mimi, a helpful candy shop mentor. Explain rules clearly and concisely."
        
        let rulesText = jars.map { "\($0.id): \($0.rule)" }.joined(separator: "\n")
        
        let userPrompt = """
        Given Rule DSL and a candy, explain in 1–2 sentences why the jar is correct.
        Rules:
        \(rulesText)
        Candy: {color: \(candy.color.rawValue), shape: \(candy.shape.rawValue), size: \(candy.size.rawValue), pattern: \(candy.pattern.rawValue), flavor: \(candy.flavor.rawValue), wrapped: \(candy.wrapped), layers: \(candy.layers)}
        Player chose jar \(jar.id). Explain succinctly.
        """
        
        makeRequest(systemPrompt: systemPrompt, userPrompt: userPrompt, apiKey: apiKey) { result in
            completion(result)
        }
    }
    
    // MARK: - Adaptive Next Round
    func generateAdaptiveRound(stats: GameStats, priorComplexity: Int, apiKey: String, completion: @escaping (Result<RoundConfig, Error>) -> Void) {
        let systemPrompt = "You are Mimi, a meticulous candy shop mentor and rigorous puzzle curator. You must output safe, deterministic JSON only."
        
        let newComplexity: Int
        if stats.accuracy >= 90 && stats.avgDropTime < 1.5 {
            newComplexity = min(10, priorComplexity + 1)
        } else if stats.accuracy < 70 {
            newComplexity = max(1, priorComplexity - 1)
        } else {
            newComplexity = priorComplexity
        }
        
        let userPrompt = """
        Player performance:
        - accuracy: \(String(format: "%.0f", stats.accuracy))%
        - avg_drop_time_sec: \(String(format: "%.1f", stats.avgDropTime))
        - streak_max: \(stats.maxStreak)
        - prior_complexity: \(priorComplexity)
        Please return JSON using the same schema as 'generate round' with target complexity \(newComplexity) and a new theme and jar labels.
        
        Rule DSL:
        - attributes: color, shape, size, pattern, flavor, wrapped, layers
        - ops: AND, OR, NOT, parentheses
        - comparisons: =, !=, ≥, ≤, >, <
        Output JSON schema:
        {
          "theme": "string",
          "concise_summary": "string (1 sentence)",
          "jars": [
            {"id":"A","label":"string readable name","rule":"Rule DSL string"},
            {"id":"B","label":"string readable name","rule":"Rule DSL string or ELSE"}
          ],
          "twist": {
            "when_seconds": number (or null),
            "description": "string",
            "patch": [{"id":"A|B","rule":"new Rule DSL string or ELSE"}]
          }
        }
        Ensure one jar uses ELSE to catch all unclassified items.
        """
        
        makeRequest(systemPrompt: systemPrompt, userPrompt: userPrompt, apiKey: apiKey) { result in
            switch result {
            case .success(let jsonString):
                do {
                    let data = jsonString.data(using: .utf8) ?? Data()
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let config = try decoder.decode(RoundConfig.self, from: data)
                    completion(.success(config))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Base Request
    private func makeRequest(systemPrompt: String, userPrompt: String, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(GPTError.missingAPIKey))
            return
        }
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(GPTError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 8.0
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "temperature": 0.3,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(GPTError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
                } else {
                    completion(.failure(GPTError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    enum GPTError: Error, LocalizedError {
        case missingAPIKey
        case invalidURL
        case noData
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "API key is missing. Please add it in Settings."
            case .invalidURL:
                return "Invalid API URL."
            case .noData:
                return "No data received from server."
            case .invalidResponse:
                return "Invalid response format."
            }
        }
    }
}
