// No arquivo: functions/index.js

const functions = require("firebase-functions");
const {GoogleGenerativeAI} = require("@google/generative-ai");
const logger = require("firebase-functions/logger");
const cors = require("cors")({origin: true});

if (process.env.NODE_ENV !== "production") {
  require("dotenv").config();
}

const apiKey = process.env.GEMINI_API_KEY || functions.config().gemini.apikey;

if (!apiKey) {
  logger.error(
      "FATAL: Chave de API do Gemini não encontrada. Verifique a config.",
  );
}

const genAI = new GoogleGenerativeAI(apiKey);
const model = genAI.getGenerativeModel({model: "gemini-pro"});

exports.evaluatePill = functions.https.onRequest((request, response) => {
  cors(request, response, async () => {
    logger.info("Iniciando avaliação de pílula...", {structuredData: true});

    try {
      if (request.method !== "POST") {
        logger.warn("Método não permitido.", {method: request.method});
        return response.status(405).json({error: "Método não permitido."});
      }

      const {
        userInput,
        validationCriteria,
        pillContent,
      } = request.body.data || {};

      if (!userInput || !validationCriteria || !validationCriteria.type) {
        logger.error("Erro: Input inválido.", {body: request.body.data});
        return response.status(400).json({
          error: "Parâmetros obrigatórios e estruturados.",
        });
      }

      let isValid = false;
      let feedback = "Não foi possível determinar a validade.";

      switch (validationCriteria.type) {
        case "string_contains_all": {
          const valuesToContain = validationCriteria.values || [];
          isValid = valuesToContain.every((val) => userInput.includes(val));
          feedback = isValid ?
            "Excelente! Seu input contém todos os elementos necessários." :
            "Seu input não contém todos os elementos esperados. Revise.";
          break;
        }
        case "url_matches_pattern": {
          const urlRegex = new RegExp(validationCriteria.pattern || "https://");
          isValid = urlRegex.test(userInput);
          feedback = isValid ?
            "URL válida! Conexão estabelecida." :
            "A URL não corresponde ao padrão esperado. Verifique o formato.";
          break;
        }
        case "string_equals": {
          isValid = userInput === validationCriteria.value;
          feedback = isValid ?
            "Correto! O valor é exatamente o esperado." :
            "O valor não corresponde. Verifique a precisão.";
          break;
        }
        case "is_number_between": {
          const numInput = parseFloat(userInput);
          isValid = !isNaN(numInput) &&
            numInput >= validationCriteria.min &&
            numInput <= validationCriteria.max;
          feedback = isValid ?
            "Número dentro do intervalo! Ótima performance." :
            "O número não está no intervalo esperado. Ajuste.";
          break;
        }
        case "string_contains_any": {
          const valuesToContainAny = validationCriteria.values || [];
          isValid = valuesToContainAny.some((val) => userInput.includes(val));
          feedback = isValid ?
            "Detectamos um dos termos chave! Bom trabalho." :
            "Nenhum dos termos chave foi encontrado. Tente novamente.";
          break;
        }
        default: {
          logger.info("Escalando para o Gemini...");
          const geminiPrompt = `
            Você é um avaliador de tarefas de bootcamp de engenharia de IA.
            Sua tarefa é avaliar a 'Resposta do Usuário' com base no 
            'Conteúdo da Pílula' e nos 'Critérios de Validação'.
            Se a 'Resposta do Usuário' for correta ou aceitável, retorne um 
            JSON: {"isValid": true, "feedback": "Seu feedback positivo aqui."}.
            Se a 'Resposta do Usuário' estiver incorreta ou precisar de 
            melhorias, retorne um JSON: {"isValid": false, "feedback": 
            "Seu feedback construtivo aqui."}.
            Seja conciso e direto.

            Conteúdo da Pílula (Contexto da Tarefa):
            ${pillContent}

            Critérios de Validação (O que é esperado):
            Tipo: ${validationCriteria.type}
            Valores/Padrões: ${JSON.stringify(
      validationCriteria.values ||
              validationCriteria.value ||
              validationCriteria.pattern ||
              (validationCriteria.min + "-" + validationCriteria.max),
  )}

            Resposta do Usuário:
            ${userInput}
          `;

          const result = await model.generateContent(geminiPrompt);
          const geminiResponseText = result.response.text();

          try {
            const geminiParsed = JSON.parse(geminiResponseText);
            isValid = geminiParsed.isValid;
            feedback = geminiParsed.feedback;
          } catch (parseError) {
            logger.error("Erro ao parsear resposta do Gemini:", {
              error: parseError,
              response: geminiResponseText,
            });
            isValid = false;
            feedback = "Erro interno na avaliação. Tente novamente.";
          }
          break;
        }
      }

      logger.info("Avaliação concluída.", {isValid, feedback});
      response.status(200).json({isValid, feedback});
    } catch (error) {
      logger.error("Erro catastrófico na função evaluatePill:", error);
      response.status(500).json({error: "Falha interna na avaliação."});
    }
  });
});
