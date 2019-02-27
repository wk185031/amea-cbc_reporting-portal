export class AppPermissionsConfiguration {
    constructor(public id?: number,
                public code?: string,
                public name?: string,
                public type?: string,
                public description?: string,
                public createdBy?: string,
                public createdDate?: any,
                public lastModifiedBy?: string,
                public lastModifiedDate?: any,
                public parent?: AppPermissionsConfiguration) {
    }
}
