Locals {
    namespaced_service_name = var.service_name
    lambdas_path = "${path.module}/../codes_lambdas"
    layers_path = "${local.lambdas_path}/layers"
    paths = {
        post = {
            description = "create a new user"
            memory = 128
            timeout = 5
        }
        delete = {
            description = "responsible for delete user"
            memory = 128
            timeout = 5
        }
        put = {
            description = "makes change, update, in any user"
            memory = 128
            timeout = 5
        }

    }

    lambdas = {
        get = {
            description = "get all users"
            memory = 256
            timeout = 10
        }
        post = {
            description = "create a new user"
            memory = 128
            timeout = 5
        }
        delete = {
            description = "responsible for delete user"
            memory = 128
            timeout = 5
        }
        put = {
            description = "makes change, update, in any user"
            memory = 128
            timeout = 5
        }
    }
}