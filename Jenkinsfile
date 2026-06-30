// Pipeline CI/CD - MobEAD - Lucas Alves
// Nome do job no Jenkins: "MobEAD - Lucas Alves - CI/CD"

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 60, unit: 'MINUTES')
        timestamps()
    }

    environment {
        APP_NAME          = 'mobead'
        DOCKER_IMAGE      = "mobead:${env.BUILD_NUMBER}"
        DEV_PORT          = '8081'
        PROD_PORT         = '8082'
        DEV_CONTAINER     = 'mobead-dev'
        PROD_CONTAINER    = 'mobead-prod'
        SONAR_PROJECT_KEY = 'mobead-lucas-alves'
        ARTIFACT_NAME     = 'mobead-artifact.tar.gz'
    }

    stages {
        stage('Checkout GitHub') {
            steps {
                echo '>>> Etapa 1: Checkout do código no GitHub'
                checkout scm
                sh 'git log -1 --oneline'
            }
        }

        stage('Instalar dependências') {
            steps {
                echo '>>> Etapa 2: Instalação de dependências Node.js'
                sh '''
                    node --version || true
                    npm --version || true
                    npm install
                '''
            }
        }

        stage('Build') {
            steps {
                echo '>>> Etapa 3: Build da aplicação'
                sh 'npm run build'
            }
        }

        stage('Testes') {
            steps {
                echo '>>> Etapa 4: Execução de testes automatizados'
                sh 'npm run test:coverage'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'test-results.xml'
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'coverage',
                        reportFiles: 'index.html',
                        reportName: 'Cobertura de Testes'
                    ])
                }
            }
        }

        stage('SonarQube') {
            steps {
                echo '>>> Etapa 5: Análise de qualidade com SonarQube'
                withSonarQubeEnv('SonarQube') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                            if [ -z "\$SONAR_TOKEN" ] || [ "\$SONAR_TOKEN" = "SUBSTITUIR_PELO_TOKEN_DO_SONARQUBE" ]; then
                                echo "ERRO: Token do SonarQube vazio ou inválido."
                                echo "Execute: ./scripts/configure-sonar-token.sh"
                                exit 1
                            fi

                            sonar-scanner \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.projectName='MobEAD - Lucas Alves' \
                                -Dsonar.sources=Scripts,lib,index.html \
                                -Dsonar.tests=tests \
                                -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
                                -Dsonar.sourceEncoding=UTF-8 \
                                -Dsonar.host.url=\${SONAR_HOST_URL} \
                                -Dsonar.token=\$SONAR_TOKEN
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo '>>> Aguardando resultado do Quality Gate no SonarQube'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('Gerar artefato') {
            steps {
                echo '>>> Etapa 6: Geração de artefato e imagem Docker'
                sh """
                    tar -czf ${ARTIFACT_NAME} \\
                        index.html kickstrap.css mine.css \\
                        Scripts Kickstrap Web.config lib
                    docker build -t ${DOCKER_IMAGE} .
                    docker tag ${DOCKER_IMAGE} mobead:latest
                """
                archiveArtifacts artifacts: "${ARTIFACT_NAME}", fingerprint: true
            }
        }

        stage('Deploy DEV') {
            steps {
                echo '>>> Etapa 7: Deploy no ambiente de desenvolvimento (porta ${DEV_PORT})'
                sh '''
                    chmod +x scripts/*.sh
                    ./scripts/deploy-dev.sh ${DOCKER_IMAGE} ${DEV_CONTAINER} ${DEV_PORT}
                '''
            }
        }

        stage('Validar DEV') {
            steps {
                echo '>>> Etapa 8: Validação da aplicação em desenvolvimento'
                sh './scripts/validate-app.sh http://${DEV_CONTAINER} DEV'
            }
        }

        stage('Aprovação para Produção') {
            steps {
                echo '>>> Etapa 9: Aguardando aprovação manual para deploy em PRODUÇÃO'
                timeout(time: 24, unit: 'HOURS') {
                    input(
                        message: 'Aprovar deploy em PRODUÇÃO? (porta 8082)',
                        ok: 'Aprovar',
                        submitterParameter: 'APROVADOR'
                    )
                }
                echo "Deploy aprovado por: ${env.APROVADOR ?: 'usuário Jenkins'}"
            }
        }

        stage('Deploy PROD') {
            steps {
                echo '>>> Etapa 10: Deploy no ambiente de produção (porta ${PROD_PORT})'
                sh './scripts/deploy-prod.sh ${DOCKER_IMAGE} ${PROD_CONTAINER} ${PROD_PORT}'
            }
        }

        stage('Validar PROD') {
            steps {
                echo '>>> Etapa 11: Validação da aplicação em produção'
                sh './scripts/validate-app.sh http://${PROD_CONTAINER} PROD'
            }
        }
    }

    post {
        success {
            echo '''
========================================
Pipeline MobEAD - Lucas Alves - CI/CD
STATUS: SUCESSO
========================================
Checkout GitHub          -> OK
Instalar dependências    -> OK
Build                    -> OK
Testes                   -> OK
SonarQube                -> OK
Gerar artefato           -> OK
Deploy DEV (8081)        -> OK
Validar DEV              -> OK
Aprovação manual         -> OK
Deploy PROD (8082)       -> OK
Validar PROD             -> OK
========================================
'''
        }
        failure {
            echo 'Pipeline MobEAD - Lucas Alves - CI/CD falhou. Verifique os logs acima.'
        }
        always {
            cleanWs(deleteDirs: true, patterns: [[pattern: 'node_modules', type: 'INCLUDE']])
        }
    }
}
