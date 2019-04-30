import { BaseEntity } from '../../shared';

export class DatabaseSynchronization implements BaseEntity {
    constructor(
        public id?: number,
        public fileDate?: string,
        public txnStart?: any,
        public txnEnd?: any,
        public generate?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public reportCategory?: BaseEntity,
        public reportDefinition?: BaseEntity
    ) {
    }
}
